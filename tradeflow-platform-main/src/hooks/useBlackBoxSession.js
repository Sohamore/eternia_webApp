import { useState, useEffect, useCallback, useRef } from "react";
import { useAuth } from "@/contexts/AuthContext";
import { getVideoSDKToken } from "@/lib/videosdk";
import api from "@/lib/api";
import { toast } from "sonner";
import { spendCredits } from "./useSpendCredits";

export function useBlackBoxSession() {
  const { user, refreshCredits } = useAuth();
  const [activeSession, setActiveSession] = useState(null);
  const [isRequesting, setIsRequesting] = useState(false);
  const [token, setToken] = useState(null);
  const [callState, setCallState] = useState("idle"); // idle | waiting | ready | joining | joined | failed
  const tokenRef = useRef(null);
  const sessionIdRef = useRef(null);
  const sessionCostRef = useRef(0);
  const pollRef = useRef(null);

  // Keep refs in sync
  useEffect(() => { tokenRef.current = token; }, [token]);
  useEffect(() => {
    const prevId = sessionIdRef.current;
    sessionIdRef.current = activeSession?.id || null;
    if (prevId && prevId !== activeSession?.id) {
      setToken(null);
      tokenRef.current = null;
      setCallState("idle");
    }
  }, [activeSession?.id]);

  // Derive callState from session status
  useEffect(() => {
    if (!activeSession) { setCallState("idle"); return; }
    const { status, room_id } = activeSession;
    if (["completed", "cancelled"].includes(status)) {
      setCallState("idle");
      setToken(null);
      tokenRef.current = null;
      return;
    }
    if (status === "queued") { setCallState("waiting"); return; }
    if ((status === "accepted" || status === "active") && room_id && !tokenRef.current) {
      setCallState("ready");
    }
  }, [activeSession?.status, activeSession?.room_id, token]);

  // Auto-connect when ready
  useEffect(() => {
    if (callState === "ready" && activeSession?.room_id && !tokenRef.current) {
      fetchToken();
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [callState, activeSession?.room_id]);

  // Poll session while queued/accepted/active
  useEffect(() => {
    if (!activeSession?.id || !["queued", "accepted", "active"].includes(activeSession.status)) {
      clearInterval(pollRef.current);
      return;
    }
    pollRef.current = setInterval(async () => {
      try {
        const { data } = await api.get(`/blackbox/sessions/${activeSession.id}`);
        if (data.session && data.session.status !== activeSession.status) {
          setActiveSession(data.session);
        }
      } catch {}
    }, 3000);
    return () => clearInterval(pollRef.current);
  }, [activeSession?.id, activeSession?.status]);

  // Check for existing active session on mount
  useEffect(() => {
    if (!user) return;
    api.get('/blackbox/sessions/active')
      .then(({ data }) => {
        if (data.sessions && data.sessions.length > 0) {
          setActiveSession(data.sessions[0]);
        }
      })
      .catch(() => {});
  }, [user]);

  // Joining timeout — 30s
  useEffect(() => {
    if (callState !== "joining") return;
    const timeout = setTimeout(async () => {
      setCallState((prev) => {
        if (prev !== "joining") return prev;
        return "failed";
      });
      if (activeSession?.id) {
        api.patch(`/blackbox/sessions/${activeSession.id}/join`, {
          error: "Connection timed out after 30s"
        }).catch(() => {});
      }
    }, 30000);
    return () => clearTimeout(timeout);
  }, [callState, activeSession?.id]);

  const fetchToken = useCallback(async () => {
    if (!activeSession?.room_id) return;
    setCallState("joining");
    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        const t = await getVideoSDKToken();
        setToken(t);
        return;
      } catch (err) {
        if (attempt === 3) {
          const msg = err.message || "Failed to connect to session";
          setCallState("failed");
          api.patch(`/blackbox/sessions/${activeSession.id}/join`, { error: msg }).catch(() => {});
          toast.error(msg);
        } else {
          await new Promise((r) => setTimeout(r, 2000));
        }
      }
    }
  }, [activeSession?.id, activeSession?.room_id]);

  const onCallJoined = useCallback(async () => {
    setCallState("joined");
    if (activeSession?.id) {
      const cost = sessionCostRef.current;
      if (cost > 0) {
        try {
          const result = await spendCredits(cost, "BlackBox Talk Now session", activeSession.id);
          if (!result.success) {
            toast.error(`Insufficient credits (${cost} ECC required)`);
          } else {
            refreshCredits();
          }
        } catch (err) {
          console.error("[BlackBox] Credit deduction failed:", err);
        }
      }
      await api.patch(`/blackbox/sessions/${activeSession.id}/join`);
    }
  }, [activeSession?.id, refreshCredits]);

  const onCallError = useCallback(async (errorMsg) => {
    setCallState("failed");
    if (activeSession?.id) {
      api.patch(`/blackbox/sessions/${activeSession.id}/join`, { error: errorMsg }).catch(() => {});
    }
  }, [activeSession?.id]);

  const requestSession = useCallback(async () => {
    if (!user) return;
    setIsRequesting(true);
    try {
      // Check daily limit
      const { data: dc } = await api.get('/blackbox/daily-count');
      if ((dc.count || 0) >= 3) {
        toast.error("Daily BlackBox limit reached (3 sessions/day)");
        return;
      }

      // Calculate tiered cost
      const { data: uc } = await api.get('/blackbox/usage-count');
      const usageCount = uc.count || 0;
      const cost = usageCount === 0 ? 0 : usageCount < 4 ? 3 : 6;

      // Pre-flight balance check
      if (cost > 0) {
        const { data: bal } = await api.get('/credits/balance');
        if ((bal.balance || 0) < cost) {
          toast.error(`Insufficient credits for a BlackBox session (${cost} ECC required)`);
          return;
        }
      }

      sessionCostRef.current = cost;

      const { data } = await api.post('/blackbox/sessions');
      setActiveSession(data.session);

      if (data.reconnected) {
        toast.info("Reconnecting to your existing session…");
      } else {
        toast.success(cost === 0
          ? "You're in the queue (first session free!). A therapist will connect shortly."
          : `You're in the queue (${cost} ECC will be charged on join).`
        );
      }
    } catch (err) {
      toast.error(err.response?.data?.error || "Failed to request session");
    } finally {
      setIsRequesting(false);
    }
  }, [user]);

  const cancelSession = useCallback(async () => {
    if (!activeSession || !user) return;
    const neverJoined = !activeSession.student_joined_at;
    try {
      await api.patch(`/blackbox/sessions/${activeSession.id}/cancel`);
      if (neverJoined) refreshCredits();
      setActiveSession(null);
      setToken(null);
      setCallState("idle");
      toast.info(neverJoined ? "Session cancelled" : "Session cancelled — no refund (already joined)");
    } catch (err) {
      toast.error(err.response?.data?.error || "Failed to cancel session");
    }
  }, [activeSession, user, refreshCredits]);

  const endSession = useCallback(async () => {
    if (!activeSession) return;
    try {
      await api.patch(`/blackbox/sessions/${activeSession.id}/end`);
      setActiveSession(null);
      setToken(null);
      setCallState("idle");
    } catch (err) {
      toast.error(err.response?.data?.error || "Failed to end session");
    }
  }, [activeSession]);

  const retryConnection = useCallback(async () => {
    setToken(null);
    tokenRef.current = null;
    await fetchToken();
  }, [fetchToken]);

  return {
    activeSession,
    isRequesting,
    callState,
    token,
    requestSession,
    cancelSession,
    endSession,
    retryConnection,
    fetchToken,
    onCallJoined,
    onCallError,
  };
}

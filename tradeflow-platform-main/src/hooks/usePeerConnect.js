import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState, useMemo, useCallback, useRef } from "react";
import { toast } from "sonner";
import { spendCredits } from "./useSpendCredits";

const MESSAGE_PAGE_SIZE = 50;
const PENDING_EXPIRY_MS = 2 * 60 * 1000;
const PEER_COST_ECC = 18;

export function usePeerConnect(initialSessionId) {
  const { user, profile, refreshCredits } = useAuth();
  const queryClient = useQueryClient();
  const [activeSessionId, setActiveSessionId] = useState(initialSessionId || null);
  const [messages, setMessages] = useState([]);
  const [hasMoreMessages, setHasMoreMessages] = useState(false);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [incomingCallSessionId, setIncomingCallSessionId] = useState(null);
  const isIntern = profile?.role === "intern";
  const pollRef = useRef(null);
  const notifPollRef = useRef(null);

  // ---------- Queries ----------

  const { data: interns = [], isLoading: isLoadingInterns } = useQuery({
    queryKey: ["interns", user?.id],
    queryFn: async () => {
      const { data } = await api.get('/peers/interns');
      return data.interns || [];
    },
    staleTime: 30_000,
    enabled: !!user,
  });

  const { data: activeSessions = [] } = useQuery({
    queryKey: ["active-peer-sessions"],
    queryFn: async () => {
      const { data } = await api.get('/peers/sessions/active');
      return data.sessions || [];
    },
    refetchInterval: 15_000,
    staleTime: 10_000,
    enabled: !!user,
  });

  const internStatuses = useMemo(() => {
    const busyIds = new Set(activeSessions.map((s) => s.intern_id).filter(Boolean));
    return Object.fromEntries(interns.map((i) => [i.id, busyIds.has(i.id) ? "busy" : "online"]));
  }, [interns, activeSessions]);

  const { data: sessions = [], isLoading: isLoadingSessions } = useQuery({
    queryKey: ["peer-sessions", user?.id, isIntern],
    queryFn: async () => {
      const { data } = await api.get('/peers/sessions');
      return data.sessions || [];
    },
    enabled: !!user,
    refetchInterval: 10_000,
    staleTime: 5_000,
  });

  // ---------- Messages ----------

  const fetchMessages = useCallback(async (sessionId, cursor) => {
    if (!sessionId) return;
    const params = new URLSearchParams({ limit: MESSAGE_PAGE_SIZE });
    if (cursor) params.set('cursor', cursor);
    const { data } = await api.get(`/peers/sessions/${sessionId}/messages?${params}`);
    const msgs = data.messages || [];
    if (!cursor) {
      setMessages(msgs.reverse()); // oldest first
    } else {
      setMessages((prev) => [...msgs.reverse(), ...prev]);
    }
    setHasMoreMessages(data.hasMore || false);
  }, []);

  useEffect(() => {
    if (activeSessionId) fetchMessages(activeSessionId);
  }, [activeSessionId, fetchMessages]);

  // Poll for new messages
  useEffect(() => {
    if (!activeSessionId) return;
    const interval = setInterval(async () => {
      try {
        const { data } = await api.get(`/peers/sessions/${activeSessionId}/messages?limit=10`);
        const fresh = (data.messages || []).reverse();
        setMessages((prev) => {
          const existingIds = new Set(prev.map((m) => m.id));
          const newOnes = fresh.filter((m) => !existingIds.has(m.id));
          return newOnes.length > 0 ? [...prev, ...newOnes] : prev;
        });
      } catch {}
    }, 3000);
    return () => clearInterval(interval);
  }, [activeSessionId]);

  // Poll notifications for incoming call
  useEffect(() => {
    if (!user) return;
    notifPollRef.current = setInterval(async () => {
      try {
        const { data } = await api.get('/notifications?limit=5');
        const callNotif = (data.notifications || []).find(
          (n) => n.type === 'peer_call' && !n.is_read
        );
        if (callNotif?.metadata?.session_id) {
          setIncomingCallSessionId(callNotif.metadata.session_id);
          // Mark as read
          api.patch(`/notifications/${callNotif.id}/read`).catch(() => {});
        }
      } catch {}
    }, 4000);
    return () => clearInterval(notifPollRef.current);
  }, [user]);

  const loadMoreMessages = useCallback(async () => {
    if (!hasMoreMessages || messages.length === 0 || isLoadingMore) return;
    setIsLoadingMore(true);
    try {
      const oldest = messages[0];
      await fetchMessages(activeSessionId, oldest?.created_at);
    } finally {
      setIsLoadingMore(false);
    }
  }, [hasMoreMessages, messages, isLoadingMore, activeSessionId, fetchMessages]);

  // ---------- Mutations ----------

  const { mutateAsync: requestSessionMutation, isPending: isRequesting } = useMutation({
    mutationFn: async (internId) => {
      const { data: bal } = await api.get('/credits/balance');
      if ((bal.balance || 0) < PEER_COST_ECC) {
        throw new Error(`Insufficient credits (${PEER_COST_ECC} ECC required)`);
      }
      const { data } = await api.post('/peers/sessions', { intern_id: internId });
      return data;
    },
    onSuccess: (result) => {
      queryClient.invalidateQueries({ queryKey: ["peer-sessions"] });
      setActiveSessionId(result.session.id);
      if (!result.existing) toast.success("Session request sent!");
    },
    onError: (err) => {
      toast.error(err.message || err.response?.data?.error || 'Failed to request session');
    },
  });

  const { mutateAsync: acceptSessionMutation, isPending: isAccepting } = useMutation({
    mutationFn: async (sessionId) => {
      // Charge student on accept
      const session = sessions.find((s) => s.id === sessionId);
      if (session) {
        try {
          await spendCredits(PEER_COST_ECC, "Peer support session", sessionId);
          refreshCredits();
        } catch (err) {
          throw new Error(`Failed to charge student: ${err.message}`);
        }
      }
      const { data } = await api.patch(`/peers/sessions/${sessionId}/accept`);
      return data;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["peer-sessions"] });
      setActiveSessionId(data.session.id);
      toast.success("Session accepted!");
    },
    onError: (err) => {
      toast.error(err.message || err.response?.data?.error || 'Failed to accept session');
    },
  });

  const { mutateAsync: declineSessionMutation } = useMutation({
    mutationFn: async (sessionId) => {
      await api.patch(`/peers/sessions/${sessionId}/decline`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["peer-sessions"] });
    },
  });

  const { mutateAsync: sendMessageMutation } = useMutation({
    mutationFn: async ({ sessionId, content }) => {
      const { data } = await api.post(`/peers/sessions/${sessionId}/messages`, { content });
      return data.message;
    },
    onSuccess: (message) => {
      setMessages((prev) => [...prev, message]);
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to send message');
    },
  });

  const { mutateAsync: flagSessionMutation } = useMutation({
    mutationFn: async ({ sessionId, escalationNote, justification }) => {
      await api.patch(`/peers/sessions/${sessionId}/flag`, {
        escalation_note: escalationNote,
        justification,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["peer-sessions"] });
      toast.success("Session flagged for review");
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to flag session');
    },
  });

  const { mutateAsync: endSessionMutation } = useMutation({
    mutationFn: async (sessionId) => {
      await api.patch(`/peers/sessions/${sessionId}/end`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["peer-sessions"] });
      setActiveSessionId(null);
      setMessages([]);
    },
  });

  const { mutateAsync: startCallMutation } = useMutation({
    mutationFn: async (sessionId) => {
      const { data } = await api.patch(`/peers/sessions/${sessionId}/start-call`);
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["peer-sessions"] });
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to start call');
    },
  });

  // ---------- Convenience wrappers ----------

  const requestSession = useCallback((internId) => requestSessionMutation(internId), [requestSessionMutation]);
  const acceptSession  = useCallback((id) => acceptSessionMutation(id), [acceptSessionMutation]);
  const declineSession = useCallback((id) => declineSessionMutation(id), [declineSessionMutation]);
  const endSession     = useCallback((id) => endSessionMutation(id || activeSessionId), [endSessionMutation, activeSessionId]);
  const flagSession    = useCallback((id, note, just) => flagSessionMutation({ sessionId: id, escalationNote: note, justification: just }), [flagSessionMutation]);
  const sendMessage    = useCallback((content, sid) => sendMessageMutation({ sessionId: sid || activeSessionId, content }), [sendMessageMutation, activeSessionId]);
  const startCall      = useCallback((id) => startCallMutation(id || activeSessionId), [startCallMutation, activeSessionId]);

  const expireSession = useCallback(async (sessionId) => {
    try {
      await api.patch(`/peers/sessions/${sessionId}/end`);
      queryClient.invalidateQueries({ queryKey: ["peer-sessions"] });
    } catch {}
  }, [queryClient]);

  const activeSession = useMemo(
    () => sessions.find((s) => s.id === activeSessionId) || null,
    [sessions, activeSessionId]
  );

  return {
    interns,
    sessions,
    activeSession,
    activeSessionId,
    setActiveSessionId,
    messages,
    hasMoreMessages,
    isLoadingMore,
    isLoadingInterns,
    isLoadingSessions,
    isRequesting,
    isAccepting,
    internStatuses,
    incomingCallSessionId,
    setIncomingCallSessionId,
    requestSession,
    acceptSession,
    declineSession,
    endSession,
    flagSession,
    sendMessage,
    startCall,
    loadMoreMessages,
    expireSession,
  };
}

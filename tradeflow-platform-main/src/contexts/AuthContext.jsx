import { createContext, useContext, useEffect, useState, useCallback, useRef } from "react";
import api from "@/lib/api";

const AuthContext = createContext(undefined);

export function AuthProvider({ children }) {
  const [user, setUser]               = useState(null);
  const [profile, setProfile]         = useState(null);
  const [creditBalance, setCreditBalance] = useState(0);
  const [isLoading, setIsLoading]     = useState(true);
  const [profileError, setProfileError] = useState(false);
  const fetchingRef = useRef(false);

  // Fetch profile + credits from /auth/me
  const fetchProfile = useCallback(async () => {
    if (fetchingRef.current) return null;
    fetchingRef.current = true;
    try {
      const { data } = await api.get('/auth/me');
      setProfile(data.user);
      setCreditBalance(data.creditBalance ?? 0);
      setProfileError(false);
      return data.user;
    } catch (err) {
      console.error("Error fetching profile:", err);
      setProfileError(true);
      return null;
    } finally {
      fetchingRef.current = false;
    }
  }, []);

  const refreshCredits = useCallback(async () => {
    try {
      const { data } = await api.get('/credits/balance');
      setCreditBalance(data.balance ?? 0);
    } catch (err) {
      console.error("Error refreshing credits:", err);
    }
  }, []);

  const refreshProfile = useCallback(async () => {
    await fetchProfile();
  }, [fetchProfile]);

  // On mount — restore session from localStorage token
  useEffect(() => {
    const token = localStorage.getItem('auth_token');
    if (!token) {
      setIsLoading(false);
      return;
    }
    fetchProfile()
      .then((p) => {
        if (p) setUser({ id: p.id });
      })
      .finally(() => setIsLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const signUp = useCallback(async (username, password, metadata = {}) => {
    try {
      const { data } = await api.post('/auth/register', { username, password, ...metadata });
      localStorage.setItem('auth_token', data.token);
      if (data.refreshToken) localStorage.setItem('refresh_token', data.refreshToken);
      setUser({ id: data.user.id });
      setProfile(data.user);
      try {
        const bal = await api.get('/credits/balance');
        setCreditBalance(bal.data.balance ?? 0);
      } catch {}
      return { error: null };
    } catch (err) {
      return { error: new Error(err.response?.data?.error || 'Registration failed') };
    }
  }, []);

  const signIn = useCallback(async (username, password) => {
    setIsLoading(true);
    setProfile(null);
    setProfileError(false);
    setCreditBalance(0);
    try {
      const { data } = await api.post('/auth/login', { username, password });
      localStorage.setItem('auth_token', data.token);
      if (data.refreshToken) localStorage.setItem('refresh_token', data.refreshToken);
      setUser({ id: data.user.id });
      setProfile(data.user);
      setCreditBalance(data.creditBalance ?? 0);
      return { error: null };
    } catch (err) {
      return { error: new Error(err.response?.data?.error || 'Login failed') };
    } finally {
      setIsLoading(false);
    }
  }, []);

  const signOut = useCallback(async () => {
    try { await api.post('/auth/logout'); } catch {}
    localStorage.removeItem('auth_token');
    localStorage.removeItem('refresh_token');
    setUser(null);
    setProfile(null);
    setCreditBalance(0);
  }, []);

  return (
    <AuthContext.Provider
      value={{
        user,
        session: user ? { user } : null,
        profile,
        creditBalance,
        isLoading,
        profileError,
        signUp,
        signIn,
        signOut,
        refreshProfile,
        refreshCredits,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) throw new Error("useAuth must be used within an AuthProvider");
  return context;
}

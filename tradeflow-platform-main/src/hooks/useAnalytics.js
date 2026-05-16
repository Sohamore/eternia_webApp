import { useEffect, useRef, useCallback } from "react";
import { useLocation } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";

// Stable session hash per browser session
let SESSION_HASH = sessionStorage.getItem('analytics_session');
if (!SESSION_HASH) {
  SESSION_HASH = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
  sessionStorage.setItem('analytics_session', SESSION_HASH);
}

function getCookieConsent() {
  try {
    return localStorage.getItem('cookie_consent') === 'accepted';
  } catch {
    return false;
  }
}

export function useAnalytics() {
  const location = useLocation();
  const { user, profile } = useAuth();
  const debounceRef = useRef(null);

  const trackPageView = useCallback((pathname) => {
    // Skip admins and users without cookie consent
    if (profile?.role === 'admin') return;
    if (!getCookieConsent()) return;

    api.post('/analytics/events', {
      session_hash: SESSION_HASH,
      event_type: 'page_view',
      page_path: pathname,
      referrer: document.referrer || null,
      user_agent: navigator.userAgent || null,
      screen_size: `${window.screen.width}x${window.screen.height}`,
    }).catch(() => {});
  }, [profile?.role]);

  useEffect(() => {
    clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      trackPageView(location.pathname);
    }, 300);

    return () => clearTimeout(debounceRef.current);
  }, [location.pathname, trackPageView]);
}

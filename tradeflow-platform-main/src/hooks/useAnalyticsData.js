import { useQuery } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { useMemo } from "react";

export function useAnalyticsData(dateRange) {
  const { profile } = useAuth();
  const isAdmin = profile?.role === 'admin';

  const { data: rawEvents = [], isLoading } = useQuery({
    queryKey: ["analytics-events", dateRange?.from, dateRange?.to],
    queryFn: async () => {
      const params = new URLSearchParams();
      if (dateRange?.from) params.set('start_date', dateRange.from.toISOString());
      if (dateRange?.to)   params.set('end_date',   dateRange.to.toISOString());
      const { data } = await api.get(`/analytics/data?${params}`);
      return data.events || [];
    },
    enabled: isAdmin,
    staleTime: 60_000,
  });

  const metrics = useMemo(() => {
    if (!rawEvents.length) return null;

    const sessionMap = new Map();
    rawEvents.forEach((e) => {
      if (!sessionMap.has(e.session_hash)) sessionMap.set(e.session_hash, []);
      sessionMap.get(e.session_hash).push(e);
    });

    const sessions = Array.from(sessionMap.values());
    const bounceCount = sessions.filter((s) => s.length === 1).length;
    const bounceRate = sessions.length > 0 ? Math.round((bounceCount / sessions.length) * 100) : 0;

    const pageViews = rawEvents.length;
    const uniqueVisitors = new Set(rawEvents.map((e) => e.session_hash)).size;

    // Top pages
    const pageCounts = rawEvents.reduce((acc, e) => {
      acc[e.page_path] = (acc[e.page_path] || 0) + 1;
      return acc;
    }, {});
    const topPages = Object.entries(pageCounts)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 10)
      .map(([path, count]) => ({ path, count }));

    // Daily trend
    const dailyCounts = rawEvents.reduce((acc, e) => {
      const day = e.created_at?.slice(0, 10);
      if (day) acc[day] = (acc[day] || 0) + 1;
      return acc;
    }, {});
    const dailyTrend = Object.entries(dailyCounts)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([date, count]) => ({ date, count }));

    // Device breakdown
    const deviceCounts = rawEvents.reduce((acc, e) => {
      const screen = e.screen_size;
      let device = 'desktop';
      if (screen) {
        const w = parseInt(screen.split('x')[0]);
        if (w < 768) device = 'mobile';
        else if (w < 1024) device = 'tablet';
      }
      acc[device] = (acc[device] || 0) + 1;
      return acc;
    }, {});

    return {
      pageViews,
      uniqueVisitors,
      bounceRate,
      topPages,
      dailyTrend,
      deviceBreakdown: deviceCounts,
      totalSessions: sessions.length,
    };
  }, [rawEvents]);

  return { metrics, isLoading, rawEvents };
}

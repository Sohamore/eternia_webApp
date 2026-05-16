import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { useEffect, useRef } from "react";

export function useNotifications() {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const audioRef = useRef(null);

  const { data: notifications = [], isLoading } = useQuery({
    queryKey: ["notifications", user?.id],
    queryFn: async () => {
      const { data } = await api.get('/notifications?limit=50');
      return data.notifications || [];
    },
    enabled: !!user,
    refetchInterval: 15_000,   // Poll every 15 s for new notifications
    staleTime: 10_000,
  });

  const unreadCount = notifications.filter((n) => !n.is_read).length;

  // Play chime on new unread notification
  const prevCountRef = useRef(0);
  useEffect(() => {
    if (unreadCount > prevCountRef.current) {
      try {
        if (!audioRef.current) {
          audioRef.current = new Audio('/notification.mp3');
        }
        audioRef.current.play().catch(() => {});
      } catch {}
    }
    prevCountRef.current = unreadCount;
  }, [unreadCount]);

  const { mutateAsync: markAsRead } = useMutation({
    mutationFn: async (notificationId) => {
      await api.patch(`/notifications/${notificationId}/read`);
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["notifications"] }),
  });

  const { mutateAsync: markAllAsRead } = useMutation({
    mutationFn: async () => {
      await api.patch('/notifications/read-all');
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["notifications"] }),
  });

  return {
    notifications,
    unreadCount,
    isLoading,
    markAsRead,
    markAllAsRead,
  };
}

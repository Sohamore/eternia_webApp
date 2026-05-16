import { useState, useCallback } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { toast } from "sonner";

export function useBlackBox() {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const [cursor, setCursor] = useState(null);
  const [allEntries, setAllEntries] = useState([]);
  const [hasMore, setHasMore] = useState(false);

  const { isLoading } = useQuery({
    queryKey: ["blackbox-entries", user?.id, cursor],
    queryFn: async () => {
      const params = new URLSearchParams({ limit: 30 });
      if (cursor) params.set('cursor', cursor);
      const { data } = await api.get(`/blackbox/entries?${params}`);
      return data;
    },
    enabled: !!user,
    staleTime: 30_000,
    onSuccess: (data) => {
      if (!cursor) {
        setAllEntries(data.entries || []);
      } else {
        setAllEntries((prev) => [...prev, ...(data.entries || [])]);
      }
      setHasMore(data.hasMore || false);
    },
  });

  // Initial load without cursor
  const { data: initialData } = useQuery({
    queryKey: ["blackbox-entries-initial", user?.id],
    queryFn: async () => {
      const { data } = await api.get('/blackbox/entries?limit=30');
      setAllEntries(data.entries || []);
      setHasMore(data.hasMore || false);
      return data;
    },
    enabled: !!user,
    staleTime: 30_000,
  });

  const loadMore = useCallback(async () => {
    if (!hasMore || allEntries.length === 0) return;
    const oldest = allEntries[allEntries.length - 1];
    setCursor(oldest.created_at);
  }, [hasMore, allEntries]);

  const { mutateAsync: createEntry, isPending: isCreating } = useMutation({
    mutationFn: async ({ content, content_type, is_private }) => {
      const { data } = await api.post('/blackbox/entries', { content, content_type, is_private });
      return data.entry;
    },
    onSuccess: async (entry) => {
      setAllEntries((prev) => [entry, ...prev]);
      queryClient.invalidateQueries({ queryKey: ["blackbox-entries-initial"] });
      // Fire-and-forget AI moderation for non-private entries
      if (!entry.is_private) {
        api.post(`/blackbox/entries/${entry.id}/moderate`).catch(() => {});
      }
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to save entry');
    },
  });

  const { mutateAsync: deleteEntry } = useMutation({
    mutationFn: async (entryId) => {
      await api.delete(`/blackbox/entries/${entryId}`);
      return entryId;
    },
    onSuccess: (entryId) => {
      setAllEntries((prev) => prev.filter((e) => e.id !== entryId));
      queryClient.invalidateQueries({ queryKey: ["blackbox-entries-initial"] });
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to delete entry');
    },
  });

  return {
    entries: allEntries,
    isLoading,
    hasMore,
    loadMore,
    createEntry,
    deleteEntry,
    isCreating,
  };
}

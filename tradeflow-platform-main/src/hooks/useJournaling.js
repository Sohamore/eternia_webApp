import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { toast } from "sonner";

export function useJournaling() {
  const { user } = useAuth();
  const queryClient = useQueryClient();

  const { data: entries = [], isLoading } = useQuery({
    queryKey: ["journal-entries", user?.id],
    queryFn: async () => {
      const { data } = await api.get('/selfhelp/journal');
      return data.entries || [];
    },
    enabled: !!user,
    staleTime: 30_000,
  });

  const { mutateAsync: addEntry, isPending: isAdding } = useMutation({
    mutationFn: async ({ title, content, mood_tag }) => {
      const { data } = await api.post('/selfhelp/journal', { title, content, mood_tag });
      return data.entry;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["journal-entries"] });
      toast.success("Journal entry saved!");
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to save entry');
    },
  });

  const { mutateAsync: deleteEntry } = useMutation({
    mutationFn: async (entryId) => {
      await api.delete(`/selfhelp/journal/${entryId}`);
      return entryId;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["journal-entries"] });
      toast.success("Entry deleted");
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to delete entry');
    },
  });

  return { entries, isLoading, addEntry, deleteEntry, isAdding };
}

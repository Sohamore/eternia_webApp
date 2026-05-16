import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { toast } from "sonner";

export function useMoodTracker() {
  const { user } = useAuth();
  const queryClient = useQueryClient();

  const { data: entries = [], isLoading } = useQuery({
    queryKey: ["mood-entries", user?.id],
    queryFn: async () => {
      const { data } = await api.get('/selfhelp/mood');
      return data.entries || [];
    },
    enabled: !!user,
    staleTime: 30_000,
  });

  const { mutateAsync: logMood, isPending: isLogging } = useMutation({
    mutationFn: async ({ mood, note }) => {
      const { data } = await api.post('/selfhelp/mood', { mood, note });
      return data.entry;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["mood-entries"] });
      toast.success("Mood logged!");
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to log mood');
    },
  });

  return { entries, isLoading, logMood, isLogging };
}

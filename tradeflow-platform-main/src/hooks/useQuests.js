import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { toast } from "sonner";

export function useQuests() {
  const { user, refreshCredits } = useAuth();
  const queryClient = useQueryClient();

  const { data: quests = [], isLoading: isLoadingQuests } = useQuery({
    queryKey: ["quest-cards"],
    queryFn: async () => {
      const { data } = await api.get('/quests');
      return data.quests || [];
    },
    staleTime: 5 * 60_000,
  });

  const { data: todayCompletions = [], isLoading: isLoadingCompletions } = useQuery({
    queryKey: ["quest-completions-today", user?.id],
    queryFn: async () => {
      const { data } = await api.get('/quests/completions/today');
      return data.completions || [];
    },
    enabled: !!user,
    staleTime: 30_000,
  });

  const completedQuestIds = new Set(todayCompletions.map((c) => c.quest_id));

  const { mutateAsync: completeQuest, isPending: isCompleting } = useMutation({
    mutationFn: async ({ quest, answer }) => {
      const { data } = await api.post('/quests/complete', { quest_id: quest.id, answer });
      return data;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["quest-completions-today"] });
      refreshCredits();
      if (data.reward > 0) {
        toast.success(`Quest completed! +${data.reward} ECC earned`);
      } else {
        toast.success("Quest completed!");
      }
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to complete quest');
    },
  });

  const completedToday = todayCompletions.length;
  const totalXpToday = todayCompletions.reduce((acc, c) => acc + (c.xp_earned || 0), 0);

  return {
    quests,
    completions: todayCompletions,
    completedQuestIds,
    isLoading: isLoadingQuests || isLoadingCompletions,
    error: null, // You could add error handling here if needed
    completedToday,
    totalXpToday,
    completeQuest,
    isCompleting,
  };
}

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { toast } from "sonner";

export function useCredits() {
  const { user, refreshCredits } = useAuth();
  const queryClient = useQueryClient();

  const { data: transactions = [], isLoading: isLoadingTransactions } = useQuery({
    queryKey: ["credit-transactions", user?.id],
    queryFn: async () => {
      const { data } = await api.get('/credits/transactions?limit=50');
      return data.transactions || [];
    },
    enabled: !!user,
    staleTime: 30_000,
  });

  const { mutateAsync: spendCreditsAsync, isPending: isSpending } = useMutation({
    mutationFn: async ({ amount, notes, reference_id }) => {
      const { data } = await api.post('/credits/spend', { amount, notes, reference_id });
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["credit-transactions"] });
      refreshCredits();
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to spend credits');
    },
  });

  const { mutateAsync: earnCreditsAsync, isPending: isEarning } = useMutation({
    mutationFn: async ({ amount, notes, reference_id }) => {
      const { data } = await api.post('/credits/earn', { amount, notes, reference_id });
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["credit-transactions"] });
      refreshCredits();
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to earn credits');
    },
  });

  return {
    transactions,
    isLoadingTransactions,
    spendCredits: spendCreditsAsync,
    earnCredits: earnCreditsAsync,
    isSpending,
    isEarning,
  };
}

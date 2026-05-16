import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { toast } from "sonner";

const WEEKLY_CAP = 5;

export function useEccEarn() {
  const { user, refreshCredits } = useAuth();
  const queryClient = useQueryClient();

  const { data: weeklyTotal = 0 } = useQuery({
    queryKey: ["weekly-earn-total", user?.id],
    queryFn: async () => {
      const { data } = await api.get('/credits/weekly-earn-total');
      return data.total || 0;
    },
    enabled: !!user,
    refetchInterval: 60_000,
    staleTime: 30_000,
  });

  const earnFromActivity = async (amount, activityName) => {
    const remaining = Math.max(0, WEEKLY_CAP - weeklyTotal);
    if (remaining <= 0) {
      toast.info('Weekly ECC earn limit reached (5 ECC/week)');
      return { earned: 0, weeklyTotal };
    }
    const actualAmount = Math.min(amount, remaining);
    try {
      const { data } = await api.post('/credits/earn', {
        amount: actualAmount,
        notes: activityName,
      });
      if (data.success) {
        queryClient.invalidateQueries({ queryKey: ["weekly-earn-total"] });
        refreshCredits();
        toast.success(`+${actualAmount} ECC earned!`);
      }
      return { earned: actualAmount, weeklyTotal: weeklyTotal + actualAmount };
    } catch (err) {
      toast.error(err.response?.data?.error || 'Failed to earn credits');
      return { earned: 0, weeklyTotal };
    }
  };

  return {
    weeklyTotal,
    weeklyRemaining: Math.max(0, WEEKLY_CAP - weeklyTotal),
    weeklyCap: WEEKLY_CAP,
    earnFromActivity,
  };
}

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { toast } from "sonner";

export function useGratitude() {
  const { user } = useAuth();
  const queryClient = useQueryClient();

  const { data: entries = [], isLoading } = useQuery({
    queryKey: ["gratitude-entries", user?.id],
    queryFn: async () => {
      const { data } = await api.get('/selfhelp/gratitude');
      return data.entries || [];
    },
    enabled: !!user,
    staleTime: 30_000,
  });

  const { mutateAsync: addEntry, isPending: isAdding } = useMutation({
    mutationFn: async ({ entry_1, entry_2, entry_3 }) => {
      const { data } = await api.post('/selfhelp/gratitude', { entry_1, entry_2, entry_3 });
      return data.entry;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["gratitude-entries"] });
      toast.success("Gratitude entry saved!");
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to save entry');
    },
  });

  return { entries, isLoading, addEntry, isAdding };
}

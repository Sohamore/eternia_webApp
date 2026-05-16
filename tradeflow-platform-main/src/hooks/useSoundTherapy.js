import { useQuery } from "@tanstack/react-query";
import api from "@/lib/api";

export function useSoundTherapy() {
  const { data: tracks = [], isLoading } = useQuery({
    queryKey: ["sound-content"],
    queryFn: async () => {
      const { data } = await api.get('/sound');
      return data.sounds || [];
    },
    staleTime: 5 * 60_000,
  });

  const categories = Array.from(new Set(tracks.map(t => t.category).filter(Boolean)));

  const formatDuration = (sec) => {
    if (!sec) return "0:00";
    const m = Math.floor(sec / 60);
    const s = Math.floor(sec % 60);
    return `${m}:${s < 10 ? "0" : ""}${s}`;
  };

  return { tracks, sounds: tracks, categories, isLoading, formatDuration };
}

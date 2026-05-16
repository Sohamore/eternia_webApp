import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";

export function useAdmin() {
  const { profile } = useAuth();
  const queryClient = useQueryClient();
  const isAdmin = profile?.role === "admin" || profile?.role === "spoc";
  const isSuperAdmin = profile?.role === "admin";

  const { data: members = [], isLoading: isLoadingMembers } = useQuery({
    queryKey: ["admin-members", isSuperAdmin ? "all" : profile?.institution_id],
    queryFn: async () => {
      const { data } = await api.get('/admin/members');
      return data.members || [];
    },
    enabled: isAdmin,
    staleTime: 30_000,
  });

  const { data: stats = { 
    totalSessions: 0, 
    activeMembers: 0, 
    flaggedCount: 0,
    appointmentCount: 0,
    peerCount: 0,
    blackboxCount: 0,
    totalCreditsEarned: 0,
    totalCreditsSpent: 0,
    activeToday: 0,
    institutionCount: 0,
    pendingEscalations: 0,
    recentSignups: 0,
    appointmentsByStatus: {}
  }, isLoading: isLoadingStats } = useQuery({
    queryKey: ["admin-stats", isSuperAdmin ? "all" : profile?.institution_id],
    queryFn: async () => {
      const { data } = await api.get('/admin/stats');
      return data.stats || { 
        totalSessions: 0, 
        activeMembers: 0, 
        flaggedCount: 0,
        appointmentCount: 0,
        peerCount: 0,
        blackboxCount: 0,
        totalCreditsEarned: 0,
        totalCreditsSpent: 0,
        activeToday: 0,
        institutionCount: 0,
        pendingEscalations: 0,
        recentSignups: 0,
        appointmentsByStatus: {}
      };
    },
    enabled: isAdmin,
    staleTime: 60_000,
  });

  const { data: institutions = [], isLoading: isLoadingInstitutions } = useQuery({
    queryKey: ["admin-institutions"],
    queryFn: async () => {
      const { data } = await api.get('/admin/institutions');
      return data.institutions || [];
    },
    enabled: isSuperAdmin,
    staleTime: 60_000,
  });

  const { data: adminAppointments = [] } = useQuery({
    queryKey: ["admin-appointments"],
    queryFn: async () => {
      const { data } = await api.get('/admin/appointments');
      return data.appointments || [];
    },
    enabled: isAdmin,
    staleTime: 30_000,
  });

  const { data: peerSessions = [] } = useQuery({
    queryKey: ["admin-peer-sessions"],
    queryFn: async () => {
      const { data } = await api.get('/admin/peer-sessions');
      return data.sessions || [];
    },
    enabled: isAdmin,
    staleTime: 30_000,
  });

  const { data: blackboxSessions = [] } = useQuery({
    queryKey: ["admin-blackbox-sessions"],
    queryFn: async () => {
      const { data } = await api.get('/admin/blackbox-sessions');
      return data.sessions || [];
    },
    enabled: isAdmin,
    staleTime: 30_000,
  });

  const { data: flaggedEntries = [] } = useQuery({
    queryKey: ["admin-flagged-entries"],
    queryFn: async () => {
      const { data } = await api.get('/admin/blackbox-entries/flagged');
      return data.entries || [];
    },
    enabled: isAdmin,
    staleTime: 30_000,
  });

  const { data: escalations = [] } = useQuery({
    queryKey: ["admin-escalations"],
    queryFn: async () => {
      const { data } = await api.get('/admin/escalations');
      return data.escalations || [];
    },
    enabled: isAdmin,
    staleTime: 30_000,
  });

  // Mutations
  const { mutateAsync: createMember, isPending: isCreating } = useMutation({
    mutationFn: async (memberData) => {
      const { data } = await api.post('/admin/members', memberData);
      return data.profile;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-members"] });
      toast.success("Member created successfully");
    },
    onError: (err) => toast.error(err.response?.data?.error || 'Failed to create member'),
  });

  const { mutateAsync: deleteMember } = useMutation({
    mutationFn: async (memberId) => {
      await api.delete(`/admin/members/${memberId}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-members"] });
      toast.success("Member removed");
    },
    onError: (err) => toast.error(err.response?.data?.error || 'Failed to delete member'),
  });

  const { mutateAsync: toggleMemberStatus } = useMutation({
    mutationFn: async ({ memberId, activate }) => {
      await api.patch(`/admin/members/${memberId}/${activate ? 'activate' : 'deactivate'}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-members"] });
    },
    onError: (err) => toast.error(err.response?.data?.error || 'Failed to update member'),
  });

  const { mutateAsync: createInstitution } = useMutation({
    mutationFn: async (instData) => {
      const { data } = await api.post('/admin/institutions', instData);
      return data.institution;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-institutions"] });
      toast.success("Institution created");
    },
    onError: (err) => toast.error(err.response?.data?.error || 'Failed to create institution'),
  });

  const { mutateAsync: deleteInstitution } = useMutation({
    mutationFn: async (institutionId) => {
      await api.delete(`/admin/institutions/${institutionId}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-institutions"] });
      toast.success("Institution deleted");
    },
    onError: (err) => toast.error(err.response?.data?.error || 'Failed to delete institution'),
  });

  const { mutateAsync: approveEscalation } = useMutation({
    mutationFn: async (escalationId) => {
      await api.patch(`/admin/escalations/${escalationId}/approve`);
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin-escalations"] }),
    onError: (err) => toast.error(err.response?.data?.error || 'Failed to approve'),
  });

  const { mutateAsync: rejectEscalation } = useMutation({
    mutationFn: async (escalationId) => {
      await api.patch(`/admin/escalations/${escalationId}/reject`);
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin-escalations"] }),
    onError: (err) => toast.error(err.response?.data?.error || 'Failed to reject'),
  });

  return {
    members,
    stats,
    institutions,
    adminAppointments,
    peerSessions,
    blackboxSessions,
    flaggedEntries,
    escalations,
    isAdmin,
    isSuperAdmin,
    isLoadingMembers,
    isLoadingStats,
    isLoadingInstitutions,
    isCreating,
    createMember,
    deleteMember,
    toggleMemberStatus,
    createInstitution,
    deleteInstitution,
    approveEscalation,
    rejectEscalation,
  };
}

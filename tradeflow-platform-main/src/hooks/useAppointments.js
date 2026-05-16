import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import api from "@/lib/api";
import { toast } from "sonner";
import { spendCredits } from "./useSpendCredits";

export function useAppointments() {
  const { user, profile, refreshCredits } = useAuth();
  const queryClient = useQueryClient();

  // Fetch active experts
  const { data: experts = [], isLoading: isLoadingExperts } = useQuery({
    queryKey: ["experts"],
    queryFn: async () => {
      const { data } = await api.get('/appointments/experts');
      return data.experts || [];
    },
    staleTime: 60_000,
  });

  // Fetch available slots
  const { data: availableSlots = [], isLoading: isLoadingSlots } = useQuery({
    queryKey: ["available-slots"],
    queryFn: async () => {
      const { data } = await api.get('/appointments/slots');
      return data.slots || [];
    },
    staleTime: 30_000,
  });

  // Fetch user's appointments
  const { data: appointments = [], isLoading: isLoadingAppointments } = useQuery({
    queryKey: ["appointments", user?.id],
    queryFn: async () => {
      const { data } = await api.get('/appointments');
      return data.appointments || [];
    },
    enabled: !!user,
    staleTime: 30_000,
  });

  // Book appointment
  const { mutateAsync: bookAppointment, isPending: isBooking } = useMutation({
    mutationFn: async ({ expertId, slotId, slotTime, sessionType, creditCost }) => {
      const { data } = await api.post('/appointments', {
        expert_id: expertId,
        slot_id: slotId,
        slot_time: slotTime,
        session_type: sessionType,
        credits_charged: creditCost
      });
      return data.appointment;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["appointments"] });
      queryClient.invalidateQueries({ queryKey: ["available-slots"] });
      toast.success("Appointment booked successfully!");
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to book appointment');
    },
  });

  // Cancel appointment
  const { mutateAsync: cancelAppointment, isPending: isCancelling } = useMutation({
    mutationFn: async (appointmentId) => {
      await api.patch(`/appointments/${appointmentId}/cancel`);
      return appointmentId;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["appointments"] });
      queryClient.invalidateQueries({ queryKey: ["available-slots"] });
      refreshCredits();
      toast.success("Appointment cancelled");
    },
    onError: (err) => {
      toast.error(err.response?.data?.error || 'Failed to cancel appointment');
    },
  });

  // Deduct credits when student joins the video call
  const deductOnJoin = async (appointmentId, creditsCharged) => {
    if (!creditsCharged || creditsCharged <= 0) return;
    try {
      const result = await spendCredits(creditsCharged, "Expert appointment session", appointmentId);
      if (!result.success) {
        toast.error(`Insufficient credits (${creditsCharged} ECC required)`);
      } else {
        refreshCredits();
      }
    } catch (err) {
      console.error("[Appointments] Credit deduction failed:", err);
    }
  };

  const upcomingAppointments = appointments.filter(a => a.status === 'confirmed' || a.status === 'pending');
  const pastAppointments = appointments.filter(a => a.status === 'completed' || a.status === 'cancelled');

  return {
    experts,
    slots: availableSlots,
    appointments,
    upcomingAppointments,
    pastAppointments,
    isLoading: isLoadingExperts || isLoadingSlots || isLoadingAppointments,
    bookAppointment,
    cancelAppointment,
    deductOnJoin,
    isBooking,
    isCancelling,
  };
}

import { useState, useCallback } from "react";
import api from "@/lib/api";
import { useAuth } from "@/contexts/AuthContext";
import { toast } from "sonner";

export const CREDIT_PACKAGES = [
  { credits: 25,  price: "₹49",  label: "Starter" },
  { credits: 60,  price: "₹99",  label: "Popular" },
  { credits: 130, price: "₹199", label: "Value" },
];

export function usePurchaseCredits() {
  const { refreshCredits } = useAuth();
  const [isLoading, setIsLoading] = useState(false);

  const initiatePayment = useCallback(async (credits) => {
    setIsLoading(true);
    try {
      // Step 1: create Razorpay order
      const { data: orderData } = await api.post('/credits/purchase/create-order', { credits });

      return new Promise((resolve, reject) => {
        const options = {
          key: orderData.key_id,
          amount: orderData.amount,
          currency: "INR",
          name: "Eternia",
          description: `${credits} ECC Credits`,
          order_id: orderData.order_id,
          handler: async (response) => {
            try {
              // Step 2: verify payment server-side
              const { data: verifyData } = await api.post('/credits/purchase/verify-payment', {
                razorpay_payment_id: response.razorpay_payment_id,
                razorpay_order_id:   response.razorpay_order_id,
                razorpay_signature:  response.razorpay_signature,
              });
              await refreshCredits();
              toast.success(`${credits} ECC credits added to your account!`);
              resolve(verifyData);
            } catch (err) {
              toast.error(err.response?.data?.error || 'Payment verification failed');
              reject(err);
            }
          },
          modal: {
            ondismiss: () => reject(new Error('Payment dismissed')),
          },
          theme: { color: "#6366f1" },
        };

        if (!window.Razorpay) {
          toast.error('Payment gateway not loaded. Please refresh and try again.');
          reject(new Error('Razorpay not loaded'));
          return;
        }

        const rzp = new window.Razorpay(options);
        rzp.on('payment.failed', (response) => {
          toast.error(`Payment failed: ${response.error.description}`);
          reject(new Error(response.error.description));
        });
        rzp.open();
      });
    } catch (err) {
      toast.error(err.response?.data?.error || 'Failed to initiate payment');
      throw err;
    } finally {
      setIsLoading(false);
    }
  }, [refreshCredits]);

  return { initiatePayment, isLoading, CREDIT_PACKAGES };
}

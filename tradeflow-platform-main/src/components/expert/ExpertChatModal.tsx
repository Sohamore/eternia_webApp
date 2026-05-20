import React, { useState, useEffect, useRef, useCallback } from "react";
import { X, Send, MessageCircle, Loader2, Smile } from "lucide-react";
import { Button } from "@/components/ui/button";
import api from "@/lib/api";

interface ExpertChatModalProps {
  isOpen: boolean;
  onClose: () => void;
  appointmentId: string | null;
  studentName?: string;
}

interface ChatMessage {
  id: string;
  sender_id: string;
  sender_type: "student" | "expert";
  content: string;
  created_at: string;
}

const EMOJI_LIST = ["😊", "👍", "❤️", "🙏", "💪", "✨", "🌟", "💡", "🎯", "🤝", "😄", "🫂"];

const ExpertChatModal: React.FC<ExpertChatModalProps> = ({
  isOpen,
  onClose,
  appointmentId,
  studentName = "Student",
}) => {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [inputText, setInputText] = useState("");
  const [isSending, setIsSending] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [showEmoji, setShowEmoji] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = useCallback(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, []);

  // Fetch messages
  const fetchMessages = useCallback(async () => {
    if (!appointmentId) return;
    try {
      const { data } = await api.get(`/appointments/${appointmentId}/messages`);
      const fetched = data.messages || [];
      setMessages((prev) => {
        // Only update if message count changed to avoid unnecessary re-renders
        if (prev.length !== fetched.length) {
          return fetched;
        }
        // Check if last message differs
        if (prev.length > 0 && fetched.length > 0 && prev[prev.length - 1].id !== fetched[fetched.length - 1].id) {
          return fetched;
        }
        return prev;
      });
      setIsLoading(false);
    } catch (err) {
      console.error("[ExpertChatModal] Failed to fetch messages:", err);
      setIsLoading(false);
    }
  }, [appointmentId]);

  // Initial fetch + polling
  useEffect(() => {
    if (!isOpen || !appointmentId) return;
    setIsLoading(true);
    fetchMessages();
    const interval = setInterval(fetchMessages, 2000);
    return () => clearInterval(interval);
  }, [isOpen, appointmentId, fetchMessages]);

  // Auto-scroll on new messages
  useEffect(() => {
    scrollToBottom();
  }, [messages, scrollToBottom]);

  // Focus input when modal opens
  useEffect(() => {
    if (isOpen) {
      setTimeout(() => inputRef.current?.focus(), 300);
    }
  }, [isOpen]);

  const handleSend = async () => {
    if (!inputText.trim() || !appointmentId || isSending) return;
    const text = inputText.trim();
    setInputText("");
    setIsSending(true);
    setShowEmoji(false);
    try {
      await api.post(`/appointments/${appointmentId}/messages`, { content: text });
      await fetchMessages();
    } catch (err) {
      console.error("[ExpertChatModal] Failed to send message:", err);
    } finally {
      setIsSending(false);
      inputRef.current?.focus();
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  const formatTime = (iso: string) => {
    try {
      const dt = new Date(iso);
      return dt.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    } catch {
      return "";
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/70 backdrop-blur-sm animate-in fade-in duration-200"
        onClick={onClose}
      />

      {/* Modal Container */}
      <div
        ref={containerRef}
        className="relative w-full max-w-lg h-[600px] max-h-[85vh] flex flex-col rounded-3xl overflow-hidden border border-emerald-500/20 shadow-[0_0_60px_rgba(16,185,129,0.12)] animate-in slide-in-from-bottom-4 fade-in duration-300"
        style={{
          background: "linear-gradient(180deg, rgba(4,11,13,0.98) 0%, rgba(8,20,24,0.98) 100%)",
        }}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-white/[0.06]">
          <div className="flex items-center gap-3">
            <div className="relative">
              <div className="absolute -inset-0.5 rounded-full bg-emerald-500/30 blur animate-pulse" />
              <div className="relative flex h-10 w-10 items-center justify-center rounded-full bg-gradient-to-br from-emerald-500 to-teal-600 text-white shadow-lg">
                <MessageCircle className="h-5 w-5" />
              </div>
            </div>
            <div>
              <h3 className="font-semibold text-white text-sm tracking-wide">
                Live Chat
              </h3>
              <p className="text-xs text-emerald-400/80 flex items-center gap-1.5">
                <span className="inline-flex h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                {studentName}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="flex h-8 w-8 items-center justify-center rounded-xl bg-white/[0.05] text-white/60 hover:bg-white/[0.1] hover:text-white transition-all"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Messages Area */}
        <div className="flex-1 overflow-y-auto px-5 py-4 space-y-3 scrollbar-thin scrollbar-track-transparent scrollbar-thumb-white/10">
          {isLoading ? (
            <div className="flex flex-col items-center justify-center h-full gap-3">
              <Loader2 className="w-7 h-7 text-emerald-500 animate-spin" />
              <p className="text-xs text-white/30 tracking-wide">Loading conversation...</p>
            </div>
          ) : messages.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full gap-4 text-center">
              <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-emerald-500/10 border border-emerald-500/20">
                <MessageCircle className="h-8 w-8 text-emerald-500/60" />
              </div>
              <div>
                <p className="text-sm text-white/50 font-medium">No messages yet</p>
                <p className="text-xs text-white/25 mt-1">
                  Say hello to {studentName} to start the conversation
                </p>
              </div>
            </div>
          ) : (
            messages.map((msg) => {
              const isExpert = msg.sender_type === "expert";
              return (
                <div
                  key={msg.id}
                  className={`flex ${isExpert ? "justify-end" : "justify-start"}`}
                >
                  <div
                    className={`max-w-[78%] px-4 py-2.5 rounded-2xl text-sm leading-relaxed transition-all ${
                      isExpert
                        ? "bg-gradient-to-br from-emerald-600/90 to-teal-700/90 text-white rounded-br-md shadow-[0_2px_12px_rgba(16,185,129,0.2)]"
                        : "bg-white/[0.07] text-white/90 rounded-bl-md border border-white/[0.05]"
                    }`}
                  >
                    <p className="whitespace-pre-wrap break-words">{msg.content}</p>
                    <p
                      className={`text-[10px] mt-1 ${
                        isExpert ? "text-emerald-200/50" : "text-white/25"
                      }`}
                    >
                      {formatTime(msg.created_at)}
                    </p>
                  </div>
                </div>
              );
            })
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Emoji Picker */}
        {showEmoji && (
          <div className="px-5 py-2 border-t border-white/[0.04] animate-in slide-in-from-bottom-2 duration-200">
            <div className="flex flex-wrap gap-2">
              {EMOJI_LIST.map((emoji) => (
                <button
                  key={emoji}
                  onClick={() => {
                    setInputText((prev) => prev + emoji);
                    inputRef.current?.focus();
                  }}
                  className="text-xl hover:scale-125 transition-transform p-1 rounded-lg hover:bg-white/[0.05]"
                >
                  {emoji}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Input Area */}
        <div className="px-5 py-4 border-t border-white/[0.06] bg-black/20">
          <div className="flex items-center gap-2">
            <button
              onClick={() => setShowEmoji(!showEmoji)}
              className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-xl transition-all ${
                showEmoji
                  ? "bg-emerald-500/20 text-emerald-400"
                  : "bg-white/[0.05] text-white/40 hover:text-white/60 hover:bg-white/[0.08]"
              }`}
            >
              <Smile className="h-4 w-4" />
            </button>
            <div className="flex-1 relative">
              <input
                ref={inputRef}
                value={inputText}
                onChange={(e) => setInputText(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Type your message..."
                className="w-full h-10 px-4 pr-4 rounded-xl bg-white/[0.06] border border-white/[0.08] text-sm text-white placeholder:text-white/25 outline-none focus:border-emerald-500/40 focus:ring-1 focus:ring-emerald-500/20 transition-all"
              />
            </div>
            <Button
              size="sm"
              disabled={!inputText.trim() || isSending}
              onClick={handleSend}
              className="h-10 w-10 shrink-0 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-black shadow-[0_2px_12px_rgba(16,185,129,0.3)] transition-all hover:scale-105 disabled:opacity-30 disabled:hover:scale-100 p-0"
            >
              {isSending ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Send className="h-4 w-4" />
              )}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ExpertChatModal;

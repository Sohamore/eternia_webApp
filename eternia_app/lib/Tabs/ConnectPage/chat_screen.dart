import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/providers/peers_provider.dart';
import 'package:eternia_ef/providers/appointments_provider.dart';

class ChatScreen extends StatefulWidget {
  final String counselorName;
  final String? sessionId;
  final bool isExpertChat;

  const ChatScreen({
    super.key,
    this.counselorName = "Counselor",
    this.sessionId,
    this.isExpertChat = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  String selectedEmoji = "😊";
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();

    // Fetch real messages if sessionId is provided
    if (widget.sessionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (widget.isExpertChat) {
          final appointmentsProvider = Provider.of<AppointmentsProvider>(context, listen: false);
          await appointmentsProvider.fetchMessages(widget.sessionId!);
          _syncMessages(appointmentsProvider.messages);

          // Start polling every 2 seconds
          _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
            if (mounted) {
              await appointmentsProvider.fetchMessages(widget.sessionId!);
              _syncMessages(appointmentsProvider.messages);
            }
          });
        } else {
          final provider = Provider.of<PeersProvider>(context, listen: false);
          await provider.fetchMessages(widget.sessionId!);
          _syncMessages(provider.messages);
        }
      });
    } else {
      // Fallback: add greeting if no session ID
      _messages.add({
        'isSent': false,
        'text': "Hello. How are you feeling today?",
        'time': "10:04 AM",
        'sender': widget.counselorName,
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _syncMessages(List<Map<String, dynamic>>? backendMessages) {
    if (backendMessages == null || !mounted) return;
    setState(() {
      _messages.clear();
      for (final msg in backendMessages) {
        final isSent = widget.isExpertChat
            ? (msg['sender_type'] == 'student')
            : (msg['sender_type'] == 'user' || msg['is_from_user'] == true);
        final createdAt = msg['created_at'] as String?;
        String timeStr = '';
        if (createdAt != null) {
          try {
            final dt = DateTime.parse(createdAt).toLocal();
            final hour = dt.hour > 12
                ? dt.hour - 12
                : (dt.hour == 0 ? 12 : dt.hour);
            final ampm = dt.hour >= 12 ? 'PM' : 'AM';
            timeStr = '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
          } catch (_) {}
        }
        _messages.add({
          'isSent': isSent,
          'text': msg['content'] as String? ?? '',
          'time': isSent ? 'DELIVERED - $timeStr' : timeStr,
          'sender': isSent ? 'You' : (widget.counselorName),
        });
      }
      // If no messages loaded, add a greeting
      if (_messages.isEmpty) {
        _messages.add({
          'isSent': false,
          'text': "Hello. How are you feeling today?",
          'time': "Now",
          'sender': widget.counselorName,
        });
      }
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:${now.minute.toString().padLeft(2, '0')} $ampm';

    setState(() {
      _messages.add({
        'isSent': true,
        'text': userText,
        'time': 'DELIVERED - $timeStr',
      });
      _controller.clear();
    });

    // Send via provider if sessionId available
    if (widget.sessionId != null) {
      if (widget.isExpertChat) {
        final appointmentsProvider = Provider.of<AppointmentsProvider>(context, listen: false);
        final success = await appointmentsProvider.sendMessage(widget.sessionId!, userText);
        if (success && mounted) {
          await appointmentsProvider.fetchMessages(widget.sessionId!);
          _syncMessages(appointmentsProvider.messages);
        }
      } else {
        final provider = Provider.of<PeersProvider>(context, listen: false);
        final success = await provider.sendMessage(widget.sessionId!, userText);
        if (success && mounted) {
          // Re-sync to get any new messages from the other party
          await provider.fetchMessages(widget.sessionId!);
          _syncMessages(provider.messages);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final bool isDark = provider.isDark;

    final Color primary = isDark
        ? const Color(0xFF67F5D4)
        : const Color(0xFF53B29A);
    final Color bg = isDark ? const Color(0xFF040B0D) : const Color(0xFFF6F3ED);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color textSecondary = isDark
        ? Colors.white38
        : const Color(0xFF70737C);
    final Color cardColor = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.white.withOpacity(0.7);
    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : const Color(0xFFE7E2D8);
    final Color sentBubbleColor = isDark
        ? const Color(0xFF15483E)
        : primary.withOpacity(0.15);
    final Color receivedBubbleColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.withOpacity(0.1);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Positioned(
          //   bottom: 0, left: 0, right: 0,
          //   child: Opacity(
          //     opacity: isDark ? 0.15 : 0.06,
          //     child: Image.asset("assets/figma/moon.png", fit: BoxFit.cover, height: 250),
          //   ),
          // ),
          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: isDark ? Colors.white70 : Colors.black54,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ETERNIA",
                                style: GoogleFonts.cormorantGaramond(
                                  color: primary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                widget.counselorName.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: textSecondary,
                                  fontSize: 9,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(
                            0xFF4A1E1E,
                          ).withOpacity(isDark ? 0.3 : 0.1),
                          border: Border.all(
                            color: const Color(
                              0xFF4A1E1E,
                            ).withOpacity(isDark ? 1.0 : 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: Color(0xFFFF8A8A),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "End Session",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFF8A8A),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _messages.length + 1, // +1 for the header card
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primary.withOpacity(0.2),
                              ),
                              color: cardColor,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: primary.withOpacity(0.1),
                                            ),
                                            child: Icon(
                                              Icons.verified_user_outlined,
                                              color: primary,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Safe Space Protocol Active",
                                              style: GoogleFonts.poppins(
                                                color: primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Your identity is shielded\nConversations vanish instantly after the session ends.",
                                        style: GoogleFonts.poppins(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 11,
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                    "assets/figma/calendar_illustration.png",
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final msg = _messages[index - 1];
                      if (msg['isSent']) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildSentMessage(
                            msg['text'],
                            msg['time'],
                            isDark: isDark,
                            primary: primary,
                            textSecondary: textSecondary,
                            bubbleColor: sentBubbleColor,
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildReceivedMessage(
                            msg['sender'],
                            msg['text'],
                            msg['time'],
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            borderColor: borderColor,
                            bubbleColor: receivedBubbleColor,
                          ),
                        );
                      }
                    },
                  ),
                ),

                // BOTTOM INPUT
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,

                                  backgroundColor: isDark
                                      ? const Color(0xFF0E1718)
                                      : Colors.white,

                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),
                                  ),

                                  builder: (context) {
                                    final emojis = [
                                      "😊",
                                      "😂",
                                      "😍",
                                      "🥺",
                                      "😎",
                                      "😭",
                                      "😡",
                                      "😴",
                                      "🤍",
                                      "🔥",
                                      "✨",
                                      "🥳",
                                      "😇",
                                      "😌",
                                      "😔",
                                      "🤗",
                                      "😅",
                                      "😋",
                                      "🙃",
                                      "💚",
                                    ];

                                    return Padding(
                                      padding: const EdgeInsets.all(14),

                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,

                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            "Choose Emoji",

                                            style: GoogleFonts.playfairDisplay(
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1B2722),

                                              fontSize: 24,

                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 24),

                                          Wrap(
                                            spacing: 14,
                                            runSpacing: 14,

                                            children: emojis.map((emoji) {
                                              final isSelected =
                                                  selectedEmoji == emoji;

                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedEmoji = emoji;
                                                  });

                                                  Navigator.pop(context);
                                                },

                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),

                                                  padding: const EdgeInsets.all(
                                                    14,
                                                  ),

                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,

                                                    color: isSelected
                                                        ? primary.withOpacity(
                                                            0.14,
                                                          )
                                                        : Colors.transparent,

                                                    border: Border.all(
                                                      color: isSelected
                                                          ? primary
                                                          : isDark
                                                          ? Colors.white12
                                                          : const Color(
                                                              0xFFE7E2D8,
                                                            ),
                                                    ),
                                                  ),

                                                  child: Text(
                                                    emoji,

                                                    style: const TextStyle(
                                                      fontSize: 28,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),

                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },

                              child: Container(
                                height: 34,
                                width: 44,

                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.03),

                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white10
                                        : const Color(0xFFE7E2D8),
                                  ),
                                ),

                                child: Center(
                                  child: Text(
                                    selectedEmoji,

                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                onSubmitted: (_) => _sendMessage(),
                                style: GoogleFonts.poppins(
                                  color: textPrimary,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Share your thoughts...",
                                  hintStyle: GoogleFonts.poppins(
                                    color: textSecondary,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _sendMessage,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primary,
                                ),
                                child: Icon(
                                  Icons.send_rounded,
                                  color: isDark
                                      ? const Color(0xFF040B0D)
                                      : Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(
    String sender,
    String message,
    String time, {
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color bubbleColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.1),
            border: Border.all(color: borderColor),
          ),
          child: Icon(
            Icons.person,
            color: isDark ? Colors.white38 : Colors.black38,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sender,
                style: GoogleFonts.poppins(color: textSecondary, fontSize: 10),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: textPrimary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: GoogleFonts.poppins(color: textSecondary, fontSize: 9),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildSentMessage(
    String message,
    String time, {
    required bool isDark,
    required Color primary,
    required Color textSecondary,
    required Color bubbleColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : const Color(0xFF1B2722),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      color: textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, color: primary, size: 12),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : primary.withOpacity(0.08),
            border: Border.all(color: primary.withOpacity(0.3)),
          ),
          child: Icon(Icons.eco, color: primary, size: 18),
        ),
      ],
    );
  }
}

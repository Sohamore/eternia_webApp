import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupName;
  final VoidCallback? onLeave;
  const GroupChatScreen({super.key, required this.groupName, this.onLeave});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _resetMessages();
  }

  void _resetMessages() {
    setState(() {
      _messages.clear();
      _messages.add({
        'sender': 'Node #112',
        'text': "Welcome to ${widget.groupName}! Glad you're here.",
        'time': 'Just now',
        'isMe': false,
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'You',
        'text': _controller.text.trim(),
        'time': 'Just now',
        'isMe': true,
      });
      _controller.clear();
    });
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
    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : const Color(0xFFE7E2D8);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // BACKGROUND DECORATION
          // Positioned(
          //   bottom: 0, left: 0, right: 0,
          //   child: Opacity(
          //     opacity: isDark ? 0.1 : 0.05,
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
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.groupName,
                            style: GoogleFonts.playfairDisplay(
                              color: textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Active Circle • 12 Online",
                            style: GoogleFonts.poppins(
                              color: primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        color: isDark ? const Color(0xFF1B2722) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (value) {
                          if (value == 'clear') {
                            _resetMessages();
                          } else if (value == 'leave') {
                            if (widget.onLeave != null) widget.onLeave!();
                            Navigator.pop(context);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'clear',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Clear Chats",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'leave',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.exit_to_app,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Leave Group",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // MESSAGES
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(
                        msg,
                        isDark,
                        primary,
                        textPrimary,
                        textSecondary,
                      );
                    },
                  ),
                ),

                // INPUT
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: GoogleFonts.poppins(
                              color: textPrimary,
                              fontSize: 13,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: GoogleFonts.poppins(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _sendMessage,
                          icon: Icon(Icons.send_rounded, color: primary),
                        ),
                      ],
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

  Widget _buildMessageBubble(
    Map<String, dynamic> msg,
    bool isDark,
    Color primary,
    Color textPrimary,
    Color textSecondary,
  ) {
    bool isMe = msg['isMe'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Text(
              msg['sender'],
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isMe
                  ? primary
                  : (isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.withOpacity(0.1)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
            ),
            child: Text(
              msg['text'],
              style: GoogleFonts.poppins(
                color: isMe
                    ? (isDark ? Colors.black : Colors.white)
                    : textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            msg['time'],
            style: GoogleFonts.poppins(color: textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

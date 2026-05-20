import 'dart:async';
import 'package:eternia_ef/Tabs/ConnectPage/chat_screen.dart';
import 'package:eternia_ef/Tabs/ConnectPage/video_call_screen.dart';
import 'package:eternia_ef/Tabs/ConnectPage/audio_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';
import 'package:eternia_ef/providers/videosdk_provider.dart';
import 'package:eternia_ef/providers/appointments_provider.dart';
import 'package:eternia_ef/screens/onboarding_screen.dart/calling_screen.dart';

class CounselorProfileScreen extends StatefulWidget {
  final String? id;
  final String name;
  final String specialty;
  final String experience;
  final String avatarUrl;

  const CounselorProfileScreen({
    super.key,
    this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.avatarUrl,
  });

  @override
  State<CounselorProfileScreen> createState() => _CounselorProfileScreenState();
}

class _CounselorProfileScreenState extends State<CounselorProfileScreen> {
  int selectedTimeIndex = 1;
  DateTime _currentMonth = DateTime(2024, 9);
  DateTime _selectedDate = DateTime(2024, 9, 3);

  final List<String> _monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    
    // Find the previous Monday (to align the grid)
    final firstMonday = firstDay.subtract(Duration(days: firstDay.weekday - 1));
    
    List<DateTime> days = [];
    for (int i = 0; i < 42; i++) {
      days.add(firstMonday.add(Duration(days: i)));
    }
    return days;
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
    final Color textSecondary = isDark ? Colors.white70 : Colors.black54;
    final Color textTertiary = isDark ? Colors.white54 : Colors.black38;
    final Color cardColor = isDark
        ? Colors.white.withOpacity(0.02)
        : Colors.white.withOpacity(0.8);
    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFFE7E2D8);
    final Color selectedDateBg = isDark
        ? const Color(0xFF15483E)
        : primary.withOpacity(0.15);
    final Color buttonBg = primary;
    final Color buttonText = isDark ? const Color(0xFF0D1418) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back, color: textTertiary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Back to Discover",
                            style: GoogleFonts.poppins(color: textTertiary, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.verified_user_outlined, color: primary, size: 24),
                  ],
                ),
                const SizedBox(height: 24),

                // TITLE
                Text(
                  "Counselor Profile",
                  style: GoogleFonts.cormorantGaramond(color: primary, fontSize: 36, fontWeight: FontWeight.w600),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 24),
                  height: 2,
                  width: 40,
                  color: isDark ? Colors.white24 : Colors.black12,
                ),

                // MAIN IMAGE
                Stack(
                  children: [
                    Container(
                      height: 380,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: primary.withOpacity(0.5), width: 1),
                        image: DecorationImage(
                          image: NetworkImage(widget.avatarUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedDateBg.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              "Certified Professional",
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // NAME & SUBTITLE
                Text(
                  widget.name,
                  style: GoogleFonts.cormorantGaramond(color: textPrimary, fontSize: 32, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  "${widget.specialty.toUpperCase()} • ${widget.experience.toUpperCase()} EXP",
                  style: GoogleFonts.poppins(color: primary.withOpacity(0.8), fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                // QUOTE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '" ',
                      style: GoogleFonts.cormorantGaramond(color: primary, fontSize: 24, fontWeight: FontWeight.w600, height: 1),
                    ),
                    Expanded(
                      child: Text(
                        "I believe healing starts with creating a safe container for your true self to emerge. My philosophy is rooted in the intersection of mindfulness and modern cognitive science, helping you navigate life's complexities with grace and resilience.\"",
                        style: GoogleFonts.poppins(color: textSecondary, fontSize: 12, height: 1.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // SPECIALIZATIONS PILLS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildPill("Anxiety", isDark: isDark, borderColor: borderColor, textSecondary: textSecondary, cardColor: cardColor),
                      const SizedBox(width: 10),
                      _buildPill("Life Transitions", isDark: isDark, borderColor: borderColor, textSecondary: textSecondary, cardColor: cardColor),
                      const SizedBox(width: 10),
                      _buildPill("Mindfulness", isDark: isDark, borderColor: borderColor, textSecondary: textSecondary, cardColor: cardColor),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // CONTACT OPTIONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildContactOption(Icons.videocam_outlined, "Video", isDark: isDark, primary: primary, borderColor: borderColor, cardColor: cardColor, textSecondary: textSecondary),
                    _buildContactOption(Icons.chat_bubble_outline, "Chat", isDark: isDark, primary: primary, borderColor: borderColor, cardColor: cardColor, textSecondary: textSecondary),
                    _buildContactOption(Icons.mic_none, "Audio", isDark: isDark, primary: primary, borderColor: borderColor, cardColor: cardColor, textSecondary: textSecondary),
                  ],
                ),
                const SizedBox(height: 40),

                // AVAILABLE SLOTS
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: primary, size: 24),
                    const SizedBox(width: 10),
                    Text("Available Slots", style: GoogleFonts.cormorantGaramond(color: textPrimary, fontSize: 26, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),

                // CALENDAR CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    color: cardColor,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_monthNames[_currentMonth.month - 1]}\n${_currentMonth.year}",
                            style: GoogleFonts.cormorantGaramond(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600, height: 1.2),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _prevMonth,
                                child: Icon(Icons.chevron_left, color: textTertiary),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _nextMonth,
                                child: Icon(Icons.chevron_right, color: textPrimary),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Timezone:", style: GoogleFonts.poppins(color: textTertiary, fontSize: 10)),
                                  Text("GMT+0", style: GoogleFonts.poppins(color: textPrimary, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                            .map((day) => Expanded(child: Center(child: Text(day, style: GoogleFonts.poppins(color: textTertiary, fontSize: 12)))))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      // CALENDAR GRID
                      ...List.generate(6, (row) {
                        final days = _getDaysInMonth(_currentMonth);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (col) {
                              final day = days[row * 7 + col];
                              final isCurrentMonth = day.month == _currentMonth.month;
                              final isSelected = day.year == _selectedDate.year && day.month == _selectedDate.month && day.day == _selectedDate.day;
                              
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (isCurrentMonth) {
                                      setState(() => _selectedDate = day);
                                    }
                                  },
                                  child: _buildDate(
                                    day.day.toString(),
                                    isCurrentMonth,
                                    isSelected: isSelected,
                                    isDark: isDark,
                                    primary: primary,
                                    selectedDateBg: selectedDateBg,
                                    textPrimary: textPrimary,
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Available Times for ${_monthNames[_selectedDate.month-1].substring(0,3)} ${_selectedDate.day}", style: GoogleFonts.poppins(color: textPrimary, fontSize: 11)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _buildTimePill("09:00 AM", 0, isDark: isDark, primary: primary, borderColor: borderColor, selectedDateBg: selectedDateBg, textPrimary: textPrimary),
                                    _buildTimePill("11:30 AM", 1, isDark: isDark, primary: primary, borderColor: borderColor, selectedDateBg: selectedDateBg, textPrimary: textPrimary),
                                    _buildTimePill("02:00 PM", 2, isDark: isDark, primary: primary, borderColor: borderColor, selectedDateBg: selectedDateBg, textPrimary: textPrimary),
                                    _buildTimePill("04:30 PM", 3, isDark: isDark, primary: primary, borderColor: borderColor, selectedDateBg: selectedDateBg, textPrimary: textPrimary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black, Colors.transparent],
                                  stops: [0.6, 1.0],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn,
                              child: Transform.translate(
                                offset: const Offset(10, 20),
                                child: Image.asset(
                                  "assets/figma/calendar_illustration.png",
                                  height: 160,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // RESERVATION
                Row(
                  children: [
                    Icon(Icons.event_available_outlined, color: primary, size: 24),
                    const SizedBox(width: 10),
                    Text("Reservation", style: GoogleFonts.cormorantGaramond(color: textPrimary, fontSize: 26, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),

                // RESERVATION CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    color: cardColor,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Session (50m)", style: GoogleFonts.poppins(color: textSecondary, fontSize: 13)),
                          Text("\$120.00", style: GoogleFonts.poppins(color: textPrimary, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Eternia Premium Disc.", style: GoogleFonts.poppins(color: textSecondary, fontSize: 13)),
                          Text("-\$15.00", style: GoogleFonts.poppins(color: primary, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE7E2D8)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total", style: GoogleFonts.cormorantGaramond(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w600)),
                          Text("\$105.00", style: GoogleFonts.poppins(color: primary, fontSize: 18, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // BOOK SESSION BUTTON
                      GestureDetector(
                        onTap: () => _showBookingSuccessDialog(context, isDark: isDark, primary: primary, buttonText: buttonText),
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: buttonBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "BOOK SESSION",
                            style: GoogleFonts.poppins(color: buttonText, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildInfoRow(Icons.security, "Privacy Guaranteed", "End-to-end encrypted sessions.", primary: primary, textPrimary: textPrimary, textTertiary: textTertiary),
                      const SizedBox(height: 20),
                      _buildInfoRow(Icons.edit_calendar_outlined, "Flexible Rescheduling", "Free up to 24h before session.", primary: primary, textPrimary: textPrimary, textTertiary: textTertiary),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String text, {required bool isDark, required Color borderColor, required Color textSecondary, required Color cardColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        color: cardColor,
      ),
      child: Text(text, style: GoogleFonts.poppins(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Future<void> _startVideoCall() async {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    final bool isDark = provider.isDark;
    final Color primary = isDark ? const Color(0xFF67F5D4) : const Color(0xFF53B29A);

    // Show a beautiful premium connection loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF040B0D) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Initiating Video Link",
                    style: GoogleFonts.cormorantGaramond(
                      color: isDark ? Colors.white : const Color(0xFF1B2722),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Connecting with ${widget.name}...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    debugPrint('[CounselorProfileScreen] StartVideoCall initiated for expert ${widget.name} with ID: ${widget.id}');
    
    bool dialogDismissed = false;
    void dismissLoadingDialog() {
      if (!dialogDismissed && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogDismissed = true;
      }
    }

    try {
      if (widget.id == null) {
        dismissLoadingDialog();
        _showDiagnosticsDialog(
          title: "Expert ID Missing",
          message: "The profile is missing a valid expert ID string. Calling is not supported for hardcoded preview counselors.",
          details: "widget.id = null\nExpert Name: ${widget.name}",
        );
        return;
      }

      // Fetch token and room ID from VideoSDKProvider
      final videoSDKProvider = Provider.of<VideoSDKProvider>(context, listen: false);
      debugPrint('[CounselorProfileScreen] Calling startNewRoom...');
      final String? roomId = await videoSDKProvider.startNewRoom().timeout(
        const Duration(seconds: 25),
        onTimeout: () => throw TimeoutException("VideoSDK room creation timed out. Please check your internet connectivity or if the backend server is reachable."),
      );

      debugPrint('[CounselorProfileScreen] Room ID fetched: $roomId, Token fetched: ${videoSDKProvider.token != null ? "YES" : "NO"}');

      if (roomId != null && videoSDKProvider.token != null) {
        final appointmentsProvider = Provider.of<AppointmentsProvider>(context, listen: false);
        debugPrint('[CounselorProfileScreen] Attempting to book appointment with expertId: ${widget.id}, roomId: $roomId');
        
        bool isBooked = await appointmentsProvider.book(
          expertId: widget.id!,
          slotTime: DateTime.now().toUtc().toIso8601String(),
          sessionType: 'video',
          roomId: roomId,
        ).timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException("Booking transaction timed out. The slotless appointment creation request did not get a response from the backend."),
        );
        
        debugPrint('[CounselorProfileScreen] Book appointment result: $isBooked, error: ${appointmentsProvider.error}');

        dismissLoadingDialog();

        if (mounted) {
          if (isBooked) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallingScreen(
                  roomId: roomId,
                  token: videoSDKProvider.token!,
                ),
              ),
            );
          } else {
            final errorMsg = appointmentsProvider.error ?? "Failed to book video session. The backend rejected the appointment booking request.";
            _showDiagnosticsDialog(
              title: "Booking Rejected",
              message: errorMsg,
              details: "Expert ID: ${widget.id}\nRoom ID: $roomId\nError from Provider: ${appointmentsProvider.error}",
            );
          }
        }
      } else {
        dismissLoadingDialog();
        final errorMsg = videoSDKProvider.error ?? "Could not create VideoSDK room. The server might have returned an invalid response.";
        _showDiagnosticsDialog(
          title: "Room Creation Failed",
          message: errorMsg,
          details: "VideoSDKProvider.error = ${videoSDKProvider.error}\nVideoSDKProvider.token = ${videoSDKProvider.token}",
        );
      }
    } catch (e, stack) {
      debugPrint('[CounselorProfileScreen] CRITICAL ERROR IN VIDEO CALL INITIATION:');
      debugPrint(e.toString());
      debugPrint(stack.toString());

      dismissLoadingDialog();
      _showDiagnosticsDialog(
        title: "Initiation Failure",
        message: "An unexpected error occurred during the call setup process.",
        details: "Exception: $e\n\nStack Trace:\n$stack",
      );
    }
  }

  Future<void> _startAudioCall() async {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    final bool isDark = provider.isDark;
    final Color primary = isDark ? const Color(0xFF67F5D4) : const Color(0xFF53B29A);

    // Show a beautiful premium connection loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF040B0D) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Initiating Audio Link",
                    style: GoogleFonts.cormorantGaramond(
                      color: isDark ? Colors.white : const Color(0xFF1B2722),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Connecting with ${widget.name}...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    debugPrint('[CounselorProfileScreen] StartAudioCall initiated for expert ${widget.name} with ID: ${widget.id}');
    
    bool dialogDismissed = false;
    void dismissLoadingDialog() {
      if (!dialogDismissed && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogDismissed = true;
      }
    }

    try {
      if (widget.id == null) {
        dismissLoadingDialog();
        _showDiagnosticsDialog(
          title: "Expert ID Missing",
          message: "The profile is missing a valid expert ID string. Calling is not supported for hardcoded preview counselors.",
          details: "widget.id = null\nExpert Name: ${widget.name}",
        );
        return;
      }

      // Fetch token and room ID from VideoSDKProvider
      final videoSDKProvider = Provider.of<VideoSDKProvider>(context, listen: false);
      debugPrint('[CounselorProfileScreen] Calling startNewRoom...');
      final String? roomId = await videoSDKProvider.startNewRoom().timeout(
        const Duration(seconds: 25),
        onTimeout: () => throw TimeoutException("VideoSDK room creation timed out. Please check your internet connectivity or if the backend server is reachable."),
      );

      debugPrint('[CounselorProfileScreen] Room ID fetched: $roomId, Token fetched: ${videoSDKProvider.token != null ? "YES" : "NO"}');

      if (roomId != null && videoSDKProvider.token != null) {
        final appointmentsProvider = Provider.of<AppointmentsProvider>(context, listen: false);
        debugPrint('[CounselorProfileScreen] Attempting to book appointment with expertId: ${widget.id}, roomId: $roomId');
        
        bool isBooked = await appointmentsProvider.book(
          expertId: widget.id!,
          slotTime: DateTime.now().toUtc().toIso8601String(),
          sessionType: 'audio',
          roomId: roomId,
        ).timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException("Booking transaction timed out. The slotless appointment creation request did not get a response from the backend."),
        );
        
        debugPrint('[CounselorProfileScreen] Book appointment result: $isBooked, error: ${appointmentsProvider.error}');

        dismissLoadingDialog();

        if (mounted) {
          if (isBooked) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallingScreen(
                  roomId: roomId,
                  token: videoSDKProvider.token!,
                  isAudioOnly: true,
                ),
              ),
            );
          } else {
            final errorMsg = appointmentsProvider.error ?? "Failed to book audio session. The backend rejected the appointment booking request.";
            _showDiagnosticsDialog(
              title: "Booking Rejected",
              message: errorMsg,
              details: "Expert ID: ${widget.id}\nRoom ID: $roomId\nError from Provider: ${appointmentsProvider.error}",
            );
          }
        }
      } else {
        dismissLoadingDialog();
        final errorMsg = videoSDKProvider.error ?? "Could not create VideoSDK room. The server might have returned an invalid response.";
        _showDiagnosticsDialog(
          title: "Room Creation Failed",
          message: errorMsg,
          details: "VideoSDKProvider.error = ${videoSDKProvider.error}\nVideoSDKProvider.token = ${videoSDKProvider.token}",
        );
      }
    } catch (e, stack) {
      debugPrint('[CounselorProfileScreen] CRITICAL ERROR IN AUDIO CALL INITIATION:');
      debugPrint(e.toString());
      debugPrint(stack.toString());

      dismissLoadingDialog();
      _showDiagnosticsDialog(
        title: "Initiation Failure",
        message: "An unexpected error occurred during the call setup process.",
        details: "Exception: $e\n\nStack Trace:\n$stack",
      );
    }
  }

  Future<void> _startChatSession() async {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    final bool isDark = provider.isDark;
    final Color primary = isDark ? const Color(0xFF67F5D4) : const Color(0xFF53B29A);

    // Show a beautiful premium connection loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF040B0D) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Initiating Secure Chat",
                    style: GoogleFonts.cormorantGaramond(
                      color: isDark ? Colors.white : const Color(0xFF1B2722),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Creating live chat channel with ${widget.name}...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    debugPrint('[CounselorProfileScreen] StartChatSession initiated for expert ${widget.name} with ID: ${widget.id}');
    
    bool dialogDismissed = false;
    void dismissLoadingDialog() {
      if (!dialogDismissed && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogDismissed = true;
      }
    }

    try {
      if (widget.id == null) {
        dismissLoadingDialog();
        _showDiagnosticsDialog(
          title: "Expert ID Missing",
          message: "The profile is missing a valid expert ID string. Chatting is not supported for hardcoded preview counselors.",
          details: "widget.id = null\nExpert Name: ${widget.name}",
        );
        return;
      }

      final appointmentsProvider = Provider.of<AppointmentsProvider>(context, listen: false);
      debugPrint('[CounselorProfileScreen] Attempting to book chat appointment with expertId: ${widget.id}');
      
      bool isBooked = await appointmentsProvider.book(
        expertId: widget.id!,
        slotTime: DateTime.now().toUtc().toIso8601String(),
        sessionType: 'chat',
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException("Booking transaction timed out. The slotless chat session creation request did not get a response from the backend."),
      );
      
      debugPrint('[CounselorProfileScreen] Book chat result: $isBooked, error: ${appointmentsProvider.error}');

      dismissLoadingDialog();

      if (mounted) {
        if (isBooked && appointmentsProvider.lastBookedAppointment != null) {
          final String sessionId = appointmentsProvider.lastBookedAppointment!['id'].toString();
          debugPrint('[CounselorProfileScreen] Navigating to ChatScreen with sessionId: $sessionId');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                counselorName: widget.name,
                sessionId: sessionId,
                isExpertChat: true,
              ),
            ),
          );
        } else {
          final errorMsg = appointmentsProvider.error ?? "Failed to book chat session. The backend rejected the appointment booking request.";
          _showDiagnosticsDialog(
            title: "Booking Rejected",
            message: errorMsg,
            details: "Expert ID: ${widget.id}\nError from Provider: ${appointmentsProvider.error}",
          );
        }
      }
    } catch (e, stack) {
      debugPrint('[CounselorProfileScreen] CRITICAL ERROR IN CHAT INITIATION:');
      debugPrint(e.toString());
      debugPrint(stack.toString());

      dismissLoadingDialog();
      _showDiagnosticsDialog(
        title: "Initiation Failure",
        message: "An unexpected error occurred during the chat channel setup process.",
        details: "Exception: $e\n\nStack Trace:\n$stack",
      );
    }
  }

  // Premium Diagnostics Alert Dialog for clear user and developer feedback
  void _showDiagnosticsDialog({
    required String title,
    required String message,
    required String details,
  }) {
    if (!mounted) return;

    final provider = Provider.of<ThemeProvider>(context, listen: false);
    final bool isDark = provider.isDark;
    final Color primary = isDark ? const Color(0xFF67F5D4) : const Color(0xFF53B29A);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool showDetails = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF071011) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.08),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.cormorantGaramond(
                              color: isDark ? Colors.white : const Color(0xFF1B2722),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Technical Details Accordion
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showDetails = !showDetails;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.07),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              showDetails ? "Hide Technical Details" : "View Technical Details",
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              showDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: isDark ? Colors.white38 : Colors.black38,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    if (showDetails) ...[
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            details,
                            style: GoogleFonts.firaCode(
                              color: isDark ? Colors.redAccent.withOpacity(0.9) : Colors.red.shade900,
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            "CLOSE",
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _startVideoCall();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: isDark ? const Color(0xFF0D1418) : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            "RETRY",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContactOption(IconData icon, String text, {required bool isDark, required Color primary, required Color borderColor, required Color cardColor, required Color textSecondary}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (text == "Chat") {
            _startChatSession();
          } else if (text == "Video") {
            _startVideoCall();
          } else if (text == "Audio") {
            _startAudioCall();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            color: cardColor,
          ),
          child: Column(
            children: [
              Icon(icon, color: primary, size: 28),
              const SizedBox(height: 12),
              Text(text, style: GoogleFonts.poppins(color: textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDate(String date, bool isCurrentMonth, {bool isSelected = false, required bool isDark, required Color primary, required Color selectedDateBg, required Color textPrimary}) {
    Color textColor;
    if (isSelected) {
      textColor = isDark ? Colors.white : primary;
    } else if (isCurrentMonth) {
      textColor = textPrimary;
    } else {
      textColor = isDark ? Colors.white10 : Colors.black12;
    }

    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: isSelected ? selectedDateBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        date,
        style: GoogleFonts.poppins(color: textColor, fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
      ),
    );
  }

  Widget _buildTimePill(String time, int index, {required bool isDark, required Color primary, required Color borderColor, required Color selectedDateBg, required Color textPrimary}) {
    bool isSelected = selectedTimeIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTimeIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.transparent : borderColor),
          color: isSelected ? selectedDateBg : Colors.transparent,
        ),
        child: Text(
          time,
          style: GoogleFonts.poppins(color: textPrimary, fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle, {required Color primary, required Color textPrimary, required Color textTertiary}) {
    return Row(
      children: [
        Icon(icon, color: primary.withOpacity(0.6), size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.poppins(color: textTertiary, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  void _showBookingSuccessDialog(BuildContext context, {required bool isDark, required Color primary, required Color buttonText}) {
    final Color dialogBg = isDark ? const Color(0xFF040B0D) : Colors.white;
    final Color dialogText = isDark ? Colors.white : const Color(0xFF1B2722);
    final Color dialogSubtext = isDark ? Colors.white70 : Colors.black54;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primary.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(color: primary.withOpacity(0.1), blurRadius: 40, spreadRadius: -10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.check_circle_outline, color: primary, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  "Session Booked!",
                  style: GoogleFonts.cormorantGaramond(color: dialogText, fontSize: 28, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  "Your session with ${widget.name} has been successfully scheduled.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: dialogSubtext, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.center,
                    child: Text(
                      "DONE",
                      style: GoogleFonts.poppins(color: buttonText, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


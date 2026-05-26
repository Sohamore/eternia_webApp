// ==========================================================
// BLACKBOX SCREEN - REDESIGNED PREMIUM INSTANT MATCHMAKING
// black_box_screen.dart
// ==========================================================

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blackbox_provider.dart';
import '../../providers/videosdk_provider.dart';
import '../../providers/socket_provider.dart';
import '../../screens/onboarding_screen.dart/calling_screen.dart';
import '../../utils/app_theme.dart';

class BlackBoxScreen extends StatefulWidget {
  const BlackBoxScreen({super.key});

  @override
  State<BlackBoxScreen> createState() => _BlackBoxScreenState();
}

class _BlackBoxScreenState extends State<BlackBoxScreen> with TickerProviderStateMixin {
  String _selectedTopic = "General guidance";
  final TextEditingController _customTopicController = TextEditingController();
  bool _isCustomTopicActive = false;

  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late AnimationController _particleController;
  
  StreamSubscription? _sessionStartedSub;
  StreamSubscription? _sessionRestoredSub;

  final List<Offset> _particlePositions = List.generate(
    15,
    (index) => Offset(math.Random().nextDouble(), math.Random().nextDouble()),
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      if (!socketProvider.isConnected) {
        socketProvider.connect();
      }

      final socketService = socketProvider.activeSession != null ? null : Provider.of<SocketProvider>(context, listen: false); // hack to get service without exposing it if we wanted, but we can just listen to provider changes or service streams.
      
      // We can listen to the provider's streams by accessing them, but since we didn't expose them in provider, we can just add listener on provider.
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    _particleController.dispose();
    _customTopicController.dispose();
    _sessionStartedSub?.cancel();
    _sessionRestoredSub?.cancel();
    super.dispose();
  }

  void _onMatchSuccess(String roomId, String token) async {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => CallingScreen(
          roomId: roomId,
          token: token,
        ),
      ),
    );
  }

  void _startMatchmaking() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    final topicText = _isCustomTopicActive ? _customTopicController.text.trim() : _selectedTopic;
    final finalTopic = topicText.isNotEmpty ? topicText : "General guidance";
    debugPrint("Matchmaking topic chosen: $finalTopic");

    socketProvider.requestMatch("expert", finalTopic);
  }

  void _cancelMatchmaking() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.cancelMatch();
  }

  void _toggleExpertOnline(bool online) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.toggleAvailability(online);
  }

  void _acceptRequest() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.acceptRequest();
  }

  void _declineRequest() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.declineRequest();
  }

  // ==========================================================
  // VIEW BUILDERS
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final socketProvider = Provider.of<SocketProvider>(context);
    final isDark = themeProvider.isDark;
    
    // Auto-launch calling screen when session is started/restored
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (socketProvider.activeSession != null) {
        final session = socketProvider.activeSession!;
        final roomId = session['meetingId'];
        final token = session['token'];
        if (roomId != null && token != null) {
          socketProvider.endSession(); // End local tracking to prevent infinite push
          _onMatchSuccess(roomId, token);
        }
      }
      if (socketProvider.lastError != null) {
        final error = socketProvider.lastError!;
        socketProvider.clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
    
    // Determine user role
    final profile = authProvider.userProfile;
    final role = profile?['role']?.toString() ?? 'student';
    final isExpertOrPeer = role != 'student';

    final Color primaryColor = AppTheme.primary(isDark);
    final Color textColor = AppTheme.text(isDark);
    final Color subTextColor = AppTheme.subText(isDark);

    return Scaffold(
      backgroundColor: AppTheme.background(isDark),
      body: Stack(
        children: [
          // Theme Background Glows
          ...AppTheme.buildBackground(isDark),

          // Custom Ambient Floating Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: FloatingParticlesPainter(
                    positions: _particlePositions,
                    progress: _particleController.value,
                    color: primaryColor.withValues(alpha: 0.12),
                  ),
                );
              },
            ),
          ),

          // Main Layout Scroll View
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Eternia",
                            style: GoogleFonts.cormorantGaramond(
                              color: primaryColor,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            isExpertOrPeer ? "Expert Portal" : "Instant Connect",
                            style: GoogleFonts.poppins(
                              color: subTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0E1718) : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border(isDark)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: isExpertOrPeer 
                                  ? (socketProvider.isAvailable ? const Color(0xFF67F5D4) : Colors.grey)
                                  : (socketProvider.isMatchmaking ? const Color(0xFF67F5D4) : Colors.grey),
                            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: const Duration(seconds: 2)),
                            const SizedBox(width: 8),
                            Text(
                              isExpertOrPeer 
                                  ? (socketProvider.isAvailable ? "Online" : "Offline")
                                  : (socketProvider.isMatchmaking ? "Matching" : "Ready"),
                              style: GoogleFonts.poppins(
                                color: textColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: AppTheme.border(isDark), height: 1),

                // Main Core Interface Block
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: isExpertOrPeer ? _buildExpertLayout(isDark, socketProvider) : _buildStudentLayout(isDark, socketProvider),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ringing Modal Overlay for Incoming Expert Requests
          if (isExpertOrPeer && socketProvider.incomingRequest != null)
            _buildIncomingRequestOverlay(isDark, socketProvider.incomingRequest!),
        ],
      ),
    );
  }

  // ==========================================================
  // STUDENT INTERFACE PANELS
  // ==========================================================

  Widget _buildStudentLayout(bool isDark, SocketProvider socketProvider) {
    final Color primaryColor = AppTheme.primary(isDark);
    final Color textColor = AppTheme.text(isDark);
    final Color subTextColor = AppTheme.subText(isDark);

    if (socketProvider.isMatchmaking) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Radar Animation Widget
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric Waves
                ...List.generate(3, (index) {
                  final delay = index * 400;
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      double val = (_pulseController.value + (delay / 2000)) % 1.0;
                      return Container(
                        width: 80 + (200 * val),
                        height: 80 + (200 * val),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withValues(alpha: (1.0 - val) * 0.25),
                            width: 1.5,
                          ),
                        ),
                      );
                    },
                  );
                }),

                // Orbiting Avatars scan line
                RotationTransition(
                  turns: _orbitController,
                  child: Stack(
                    children: [
                      // Orbit Path Card
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
                        ),
                      ),
                      // Dummy Orbiting Avatar 1
                      Positioned(
                        top: 20,
                        left: 140,
                        child: _buildRadarAvatar("assets/figma/Forest.png"),
                      ),
                      // Dummy Orbiting Avatar 2
                      Positioned(
                        bottom: 40,
                        right: 30,
                        child: _buildRadarAvatar("assets/figma/wave.png"),
                      ),
                    ],
                  ),
                ),

                // Pulsing Center Core Connection Card
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Searching for available experts...",
            style: GoogleFonts.cormorantGaramond(
              color: textColor,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Topic: ${ _isCustomTopicActive ? _customTopicController.text : _selectedTopic }",
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          // Cancel Action Call
          GestureDetector(
            onTap: _cancelMatchmaking,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1B1B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Cancel Request",
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // IDLE Matchmaking Screen State
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Get Connected",
          style: GoogleFonts.cormorantGaramond(
            color: textColor,
            fontSize: 42,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Instantly link with a random active peer counselor, student leader, or qualified campus expert.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: subTextColor,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 48),

        // Connect Pulse central button
        GestureDetector(
          onTap: _startMatchmaking,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating animated rings
              ...List.generate(2, (index) {
                final delay = index * 800;
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    double val = (_pulseController.value + (delay / 1600)) % 1.0;
                    return Container(
                      width: 140 + (100 * val),
                      height: 140 + (100 * val),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withValues(alpha: (1.0 - val) * 0.2),
                          width: 2,
                        ),
                      ),
                    );
                  },
                );
              }),

              // Central Button
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: isDark ? Colors.black : Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "CONNECT NOW",
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),

        // Topic select / customized request
        _buildTopicSelector(isDark),
      ],
    );
  }

  Widget _buildRadarAvatar(String imagePath) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Color(0xFF67F5D4),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage(imagePath),
      ),
    );
  }

  Widget _buildTopicSelector(bool isDark) {
    final Color borderCol = AppTheme.border(isDark);
    final Color activeCol = AppTheme.primary(isDark);
    final Color labelColor = AppTheme.text(isDark);

    final List<String> defaultTopics = ["General guidance", "Academic Stress", "Anxiety", "Peer Support"];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E1718).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Conversation Focus",
            style: GoogleFonts.poppins(
              color: labelColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...defaultTopics.map((topic) {
                final isSelected = !_isCustomTopicActive && _selectedTopic == topic;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCustomTopicActive = false;
                      _selectedTopic = topic;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? activeCol.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? activeCol : borderCol,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      topic,
                      style: GoogleFonts.poppins(
                        color: isSelected ? activeCol : AppTheme.subText(isDark),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isCustomTopicActive = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isCustomTopicActive ? activeCol.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isCustomTopicActive ? activeCol : borderCol,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    "Custom topic +",
                    style: GoogleFonts.poppins(
                      color: _isCustomTopicActive ? activeCol : AppTheme.subText(isDark),
                      fontSize: 12,
                      fontWeight: _isCustomTopicActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isCustomTopicActive) ...[
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: TextField(
                controller: _customTopicController,
                style: GoogleFonts.poppins(color: labelColor, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "E.g., feeling overwhelmed with exams...",
                  hintStyle: GoogleFonts.poppins(color: AppTheme.subText(isDark).withValues(alpha: 0.5), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // EXPERT INTERFACE PANELS
  // ==========================================================

  Widget _buildExpertLayout(bool isDark, SocketProvider socketProvider) {
    final Color textColor = AppTheme.text(isDark);
    final Color subTextColor = AppTheme.subText(isDark);
    final Color cardBg = isDark ? const Color(0xFF0E1718) : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Expert Dashboard",
          style: GoogleFonts.cormorantGaramond(
            color: textColor,
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Set your online availability status. When active, incoming student matches will prompt on your screen.",
          style: GoogleFonts.poppins(
            color: subTextColor,
            fontSize: 13,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),

        // availability card toggle switch
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border(isDark)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: socketProvider.isAvailable ? const Color(0xFF67F5D4).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      socketProvider.isAvailable ? Icons.wifi_calling_3_rounded : Icons.phone_disabled_rounded,
                      color: socketProvider.isAvailable ? const Color(0xFF67F5D4) : Colors.grey,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Matchmaking Node",
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        socketProvider.isAvailable ? "Awaiting matches..." : "Offline mode",
                        style: GoogleFonts.poppins(
                          color: subTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch.adaptive(
                value: socketProvider.isAvailable,
                activeThumbColor: const Color(0xFF67F5D4),
                onChanged: _toggleExpertOnline,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Quick Stats row
        Row(
          children: [
            Expanded(
              child: _buildExpertStatCard(
                isDark,
                "Node Queue",
                socketProvider.isAvailable ? "Monitoring" : "Inactive",
                Icons.radar,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExpertStatCard(
                isDark,
                "Completed",
                "0",
                Icons.block_flipped,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpertStatCard(bool isDark, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A1111) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: AppTheme.subText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: AppTheme.primary(isDark), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppTheme.text(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RINGING POPUP OVERLAY
  // ==========================================================

  Widget _buildIncomingRequestOverlay(bool isDark, Map<String, dynamic> incomingRequest) {
    final String studentName = incomingRequest['studentName'] ?? "Anonymous Peer";
    final String topic = incomingRequest['topic'] ?? "General guidance";

    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF040B0D) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF67F5D4).withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF67F5D4).withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ringing Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(2, (index) {
                    final delay = index * 600;
                    return AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        double val = (_pulseController.value + (delay / 1200)) % 1.0;
                        return Container(
                          width: 80 + (60 * val),
                          height: 80 + (60 * val),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF67F5D4).withValues(alpha: (1.0 - val) * 0.4),
                              width: 2.5,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFF67F5D4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_callback_rounded,
                      color: Colors.black,
                      size: 38,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                "Incoming Support Call",
                style: GoogleFonts.cormorantGaramond(
                  color: AppTheme.text(isDark),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "From: $studentName",
                style: GoogleFonts.poppins(
                  color: AppTheme.text(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Topic: $topic",
                  style: GoogleFonts.poppins(
                    color: AppTheme.subText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 38),

              // Action buttons Accept/Decline
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _declineRequest,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "DECLINE",
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _acceptRequest,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF67F5D4), Color(0xFF53B29A)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF67F5D4).withValues(alpha: 0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "ACCEPT",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// CUSTOM FLOAT PARTICLE PAINTER
// ==========================================================

class FloatingParticlesPainter extends CustomPainter {
  final List<Offset> positions;
  final double progress;
  final Color color;

  FloatingParticlesPainter({
    required this.positions,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];
      // Vertical translation offset over time
      double dx = pos.dx * size.width;
      double dy = ((pos.dy - (progress * 0.15)) % 1.0) * size.height;

      // Particle breathing radius
      double radius = 4 + (3 * math.sin((progress * 2 * math.pi) + i));

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FloatingParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:eternia_ef/providers/theme_provider.dart';

class CallingScreen extends StatefulWidget {
  final String roomId;
  final String token;
  final bool isAudioOnly;

  const CallingScreen({
    Key? key,
    required this.roomId,
    required this.token,
    this.isAudioOnly = false,
  }) : super(key: key);

  @override
  _CallingScreenState createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  Room? _room;
  Map<String, Participant> _participants = {};
  bool _isConnecting = true;
  String? _errorMessage;
  bool _micEnabled = true;
  bool _camEnabled = true;
  double _pulseTarget = 1.0;

  @override
  void initState() {
    super.initState();
    _camEnabled = !widget.isAudioOnly;
    _initRoomAndJoin();
  }

  Future<void> _initRoomAndJoin() async {
    // 1. Request microphone and camera permissions
    final List<Permission> permissions = [Permission.microphone];
    if (!widget.isAudioOnly) {
      permissions.add(Permission.camera);
    }

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    if (statuses[Permission.microphone] != PermissionStatus.granted ||
        (!widget.isAudioOnly &&
            statuses[Permission.camera] != PermissionStatus.granted)) {
      setState(() {
        _isConnecting = false;
        _errorMessage = widget.isAudioOnly
            ? "Microphone permission is required to make audio calls."
            : "Camera and microphone permissions are required to make video calls.";
      });
      return;
    }

    try {
      // 2. Initialize VideoSDK Room
      _room = VideoSDK.createRoom(
        roomId: widget.roomId,
        token: widget.token,
        displayName: "Student",
        micEnabled: _micEnabled,
        camEnabled: _camEnabled,
      );

      _setupRoomEventListener();
      _room?.join();
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _errorMessage = "Failed to start call: $e";
      });
    }
  }

  void _setupRoomEventListener() {
    _room?.on(Events.roomJoined, () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _participants = _room!.participants;
        });
      }
    });

    _room?.on(Events.participantJoined, (Participant participant) {
      if (mounted) {
        setState(() {
          _participants[participant.id] = participant;
        });
      }
    });

    _room?.on(Events.participantLeft, (String participantId) {
      if (mounted) {
        setState(() {
          _participants.remove(participantId);
        });
      }
    });

    _room?.on(Events.roomLeft, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });

    _room?.on(Events.error, (error) {
      if (mounted) {
        setState(() {
          _errorMessage =
              error['message'] ?? "An unexpected video call error occurred.";
        });
      }
    });
  }

  void _toggleMic() {
    if (_room != null) {
      if (_micEnabled) {
        _room!.muteMic();
      } else {
        _room!.unmuteMic();
      }
      setState(() {
        _micEnabled = !_micEnabled;
      });
    }
  }

  void _toggleCam() {
    if (_room != null) {
      if (_camEnabled) {
        _room!.disableCam();
      } else {
        _room!.enableCam();
      }
      setState(() {
        _camEnabled = !_camEnabled;
      });
    }
  }

  void _leaveRoom() {
    _room?.leave();
  }

  @override
  void dispose() {
    _room?.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final primary = isDark ? const Color(0xFF67F5D4) : const Color(0xFF53B29A);

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF040B0D),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Connection Failed",
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      "Go Back",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF040B0D),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isConnecting) {
      return Scaffold(
        backgroundColor: const Color(0xFF040B0D),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background cosmic elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.08),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated-like radar pulse
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: _pulseTarget),
                    duration: const Duration(seconds: 2),
                    onEnd: () {
                      if (mounted) {
                        setState(() {
                          _pulseTarget = _pulseTarget == 1.0 ? 0.0 : 1.0;
                        });
                      }
                    },
                    builder: (context, value, child) {
                      return Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(
                            alpha: 0.05 + (0.05 * (1 - value)),
                          ),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.3 * (1 - value)),
                            width: 1 + (2 * value),
                          ),
                        ),
                        child: Center(
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: primary.withValues(alpha: 0.15),
                            child: Icon(
                              widget.isAudioOnly ? Icons.phone : Icons.videocam,
                              color: primary,
                              size: 28,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Connecting to Room...",
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.isAudioOnly
                        ? "Securing high-quality audio call link"
                        : "Securing high-quality video call link",
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Participants list
    final List<Participant> remoteParticipants = _participants.values.toList();
    final bool hasRemote = remoteParticipants.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── REMOTE PARTICIPANT VIEW (Full Screen Background) ──
          if (hasRemote)
            ParticipantTile(
              participant: remoteParticipants.first,
              isLocal: false,
            )
          else
            // Waiting Screen when nobody is in the room yet
            _buildWaitingScreen(primary),

          // ── LOCAL PARTICIPANT VIEW (FaceTime / PiP Style Overlay) ──
          if (_room != null)
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                width: 110,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ParticipantTile(
                  participant: _room!.localParticipant,
                  isLocal: true,
                ),
              ),
            ),

          // ── TOP PANEL INFO (Room details) ──
          Positioned(
            top: 50,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  color: Colors.white.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Live Session",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── BOTTOM FLOATING CONTROLS ──
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  color: Colors.white.withValues(alpha: 0.06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mic toggle button
                      _buildControlButton(
                        icon: _micEnabled ? Icons.mic : Icons.mic_off,
                        isActive: _micEnabled,
                        onTap: _toggleMic,
                      ),
                      // Leave call button (Red Accent)
                      GestureDetector(
                        onTap: _leaveRoom,
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      // Cam toggle button
                      if (!widget.isAudioOnly)
                        _buildControlButton(
                          icon: _camEnabled
                              ? Icons.videocam
                              : Icons.videocam_off,
                          isActive: _camEnabled,
                          onTap: _toggleCam,
                        )
                      else
                        const SizedBox(width: 52, height: 52),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingScreen(Color primary) {
    return Container(
      color: const Color(0xFF040B0D),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulse animation waiting
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: _pulseTarget),
                duration: const Duration(seconds: 3),
                onEnd: () {
                  if (mounted) {
                    setState(() {
                      _pulseTarget = _pulseTarget == 1.0 ? 0.0 : 1.0;
                    });
                  }
                },
                builder: (context, value, child) {
                  return Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withValues(
                        alpha: 0.02 + (0.03 * (1 - value)),
                      ),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.2 * (1 - value)),
                        width: 1 + (1.5 * value),
                      ),
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white.withValues(alpha: 0.02),
                        backgroundImage: const NetworkImage(
                          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&q=80",
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                "Waiting for expert...",
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.isAudioOnly
                    ? "Your counselor will join the session shortly. Please ensure your microphone is ready."
                    : "Your counselor will join the session shortly. Please ensure your camera and microphone are ready.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white24,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white54,
          size: 22,
        ),
      ),
    );
  }
}

// ── CUSTOM PARTICIPANT TILE WIDGET FOR EVENT-DRIVEN WEBRTC STREAM RENDER ──
class ParticipantTile extends StatefulWidget {
  final Participant participant;
  final bool isLocal;

  const ParticipantTile({
    Key? key,
    required this.participant,
    required this.isLocal,
  }) : super(key: key);

  @override
  _ParticipantTileState createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  dynamic videoStream;

  @override
  void initState() {
    super.initState();
    _initStream();
    _setupListeners();
  }

  void _initStream() {
    widget.participant.streams.forEach((key, stream) {
      if (stream.kind == 'video') {
        setState(() {
          videoStream = stream;
        });
      }
    });
  }

  void _setupListeners() {
    widget.participant.on(Events.streamEnabled, _onStreamEnabled);
    widget.participant.on(Events.streamDisabled, _onStreamDisabled);
  }

  void _onStreamEnabled(dynamic stream) {
    if (stream.kind == 'video') {
      setState(() {
        videoStream = stream;
      });
    }
  }

  void _onStreamDisabled(dynamic stream) {
    if (stream.kind == 'video') {
      setState(() {
        videoStream = null;
      });
    }
  }

  @override
  void dispose() {
    widget.participant.off(Events.streamEnabled, _onStreamEnabled);
    widget.participant.off(Events.streamDisabled, _onStreamDisabled);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoStream != null && videoStream.renderer != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: RTCVideoView(
          videoStream.renderer as RTCVideoRenderer,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          mirror: widget.isLocal,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F11),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: widget.isLocal ? 22 : 44,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              child: Text(
                widget.participant.displayName.isNotEmpty
                    ? widget.participant.displayName[0].toUpperCase()
                    : "?",
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white,
                  fontSize: widget.isLocal ? 20 : 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.isLocal
                  ? "Camera Off"
                  : "${widget.participant.displayName}",
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: widget.isLocal ? 10 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

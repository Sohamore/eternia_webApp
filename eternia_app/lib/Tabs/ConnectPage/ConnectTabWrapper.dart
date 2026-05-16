// ==========================================================
// CONNECT TAB WRAPPER
// ConnectTabWrapper.dart
// ==========================================================

import 'package:flutter/material.dart';
import 'package:eternia_ef/Tabs/ConnectPage/connect_home_screen.dart';
import 'package:eternia_ef/Tabs/ConnectPage/expert_guidance_screen.dart';
import 'package:eternia_ef/Tabs/ConnectPage/chat_screen.dart';
import 'package:eternia_ef/Tabs/ConnectPage/counselor_profile_screen.dart';
import 'package:eternia_ef/Tabs/ConnectPage/peer_option_screen.dart';
import 'package:eternia_ef/Tabs/ConnectPage/group_session_screen.dart';

class ConnectTabWrapper extends StatefulWidget {
  const ConnectTabWrapper({super.key});

  @override
  State<ConnectTabWrapper> createState() => _ConnectTabWrapperState();
}

class _ConnectTabWrapperState extends State<ConnectTabWrapper> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_navigatorKey.currentState != null && _navigatorKey.currentState!.canPop()) {
          _navigatorKey.currentState!.pop();
          return false;
        }
        return true;
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (BuildContext context) {
              switch (settings.name) {
                case '/':
                  return ConnectHomeScreen(
                    onExpertConnect: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const ExpertGuidanceScreen()),
                      );
                    },
                    onPeerConnect: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => PeerOptionScreen(
                            onPeerSelected: (name) {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(builder: (_) => const ChatScreen()),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    onJoinSession: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const GroupSessionScreen()),
                      );
                    },
                  );
                case '/expert-guidance':
                  return const ExpertGuidanceScreen();
                case '/peer-options':
                  return PeerOptionScreen(
                    onPeerSelected: (name) {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    },
                  );
                case '/chat':
                  return const ChatScreen();
                case '/group-session':
                  return const GroupSessionScreen();
                case '/counselor-profile':
                  return const CounselorProfileScreen(
                    name: "Dr. Aria Vance",
                    specialty: "Psychologist",
                    experience: "10 Years",
                    avatarUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&q=80",
                  );
                default:
                  return ConnectHomeScreen(
                    onExpertConnect: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const ExpertGuidanceScreen()),
                      );
                    },
                    onPeerConnect: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => PeerOptionScreen(
                            onPeerSelected: (name) {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(builder: (_) => const ChatScreen()),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    onJoinSession: () => _navigatorKey.currentState?.pushNamed('/group-session'),
                  );
              }
            },
          );
        },
      ),
    );
  }
}

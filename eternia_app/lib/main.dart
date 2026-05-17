import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/token_storage.dart';
import 'core/api_client.dart';

import 'services/auth_service.dart';
import 'services/credits_service.dart';
import 'services/appointments_service.dart';
import 'services/peers_service.dart';
import 'services/blackbox_service.dart';
import 'services/quests_service.dart';
import 'services/sound_service.dart';
import 'services/selfhelp_service.dart';
import 'services/notifications_service.dart';
import 'services/profiles_service.dart';

import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/credits_provider.dart';
import 'providers/appointments_provider.dart';
import 'providers/peers_provider.dart';
import 'providers/blackbox_provider.dart';
import 'providers/quests_provider.dart';
import 'providers/sound_provider.dart';
import 'providers/selfhelp_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/profiles_provider.dart';

import 'screens/onboarding_screen.dart/onboarding_screen.dart';
import 'screens/onboarding_screen.dart/VerifyCampusScreen.dart';
import 'screens/onboarding_screen.dart/InstitutionalScanScreen.dart';
import 'Tabs/home_screen/MainNavigation.dart';

void main() {
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage: tokenStorage);

  final authService = AuthService(apiClient);
  final creditsService = CreditsService(apiClient);
  final appointmentsService = AppointmentsService(apiClient);
  final peersService = PeersService(apiClient);
  final blackBoxService = BlackBoxService(apiClient);
  final questsService = QuestsService(apiClient);
  final soundService = SoundService(apiClient);
  final selfHelpService = SelfHelpService(apiClient);
  final notificationsService = NotificationsService(apiClient);
  final profilesService = ProfilesService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            tokenStorage: tokenStorage,
          ),
        ),
        ChangeNotifierProvider(create: (_) => CreditsProvider(creditsService)),
        ChangeNotifierProvider(
          create: (_) => AppointmentsProvider(appointmentsService),
        ),
        ChangeNotifierProvider(create: (_) => PeersProvider(peersService)),
        ChangeNotifierProvider(
          create: (_) => BlackBoxProvider(blackBoxService),
        ),
        ChangeNotifierProvider(create: (_) => QuestsProvider(questsService)),
        ChangeNotifierProvider(create: (_) => SoundProvider(soundService)),
        ChangeNotifierProvider(
          create: (_) => SelfHelpProvider(selfHelpService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationsProvider(notificationsService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfilesProvider(profilesService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const _AuthWrapper(),
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isInitializing) {
      return const _SplashScreen();
    }

    if (!auth.isAuthenticated) {
      return const OnboardingScreen();
    }

    // ── Authenticated: determine onboarding step ──
    final profile = auth.userProfile;

    // Step 1: Institution not verified yet → show campus code entry
    final institutionId = profile?['institution_id'] as String?;
    if (institutionId == null) {
      return const VerifyCampusScreen();
    }

    // Step 2: Institution linked but QR/ID not verified → show scan screen
    final isVerified = profile?['is_verified'] as bool? ?? false;
    if (!isVerified) {
      return InstitutionalScanScreen(institutionId: institutionId);
    }

    // Step 3: Verified — go to main app
    return const MainNavigation();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final primary = isDark ? const Color(0xFF67F5D4) : const Color(0xFF53B29A);
    final bg = isDark ? const Color(0xFF071011) : const Color(0xFFF6F3ED);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ETERNIA',
              style: GoogleFonts.cormorantGaramond(
                color: primary,
                fontSize: 42,
                letterSpacing: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: primary),
            ),
          ],
        ),
      ),
    );
  }
}

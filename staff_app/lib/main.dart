import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';

import 'features/auth/auth_screen.dart';
import 'features/alerts/alerts_screen.dart';
import 'features/alerts/alert_detail_screen.dart';
import 'features/map/map_screen.dart';
import 'features/map/room_sweep_checklist.dart';
import 'features/broadcast/broadcast_screen.dart';
import 'features/incident_log/log_screen.dart';
import 'models/alert.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Firebase Initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: ResqnetStaffApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthScreen(),
    ),

    GoRoute(
      path: '/alerts',
      builder: (context, state) => const AlertsScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final alert = state.extra as Alert;
            return AlertDetailScreen(
              alert: alert,
            );
          },
        ),
      ],
    ),

    GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),

    GoRoute(
      path: '/checklist',
      builder: (context, state) =>
          const RoomSweepChecklistScreen(),
    ),

    GoRoute(
      path: '/broadcast',
      builder: (context, state) =>
          const BroadcastScreen(),
    ),

    GoRoute(
      path: '/logs',
      builder: (context, state) =>
          const IncidentLogScreen(),
    ),
  ],
);

class ResqnetStaffApp extends StatelessWidget {
  const ResqnetStaffApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RESQNET Staff',
      debugShowCheckedModeBanner: false,

      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor:
            const Color(0xFFF8F9FF),

        primaryColor:
            const Color(0xFF2A5A9C),

        colorScheme:
            const ColorScheme.light(
          primary: Color(0xFF2A5A9C),
          secondary: Color(0xFFB6171E),
          tertiary: Color(0xFF1E6816),
          surface: Color(0xFFFFFFFF),
          error: Color(0xFFBA1A1A),
          onSurface: Color(0xFF021D34),
        ),

        textTheme:
            GoogleFonts.spaceGroteskTextTheme(
          ThemeData.light().textTheme,
        ).apply(
          bodyColor:
              const Color(0xFF021D34),
          displayColor:
              const Color(0xFF021D34),
        ),

        appBarTheme:
            const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor:
              Color(0xFFFFFFFF),
          foregroundColor:
              Color(0xFF021D34),
          surfaceTintColor:
              Colors.transparent,
        ),
      ),

      routerConfig: _router,
    );
  }
} 
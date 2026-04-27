import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/auth_screen.dart';
import 'features/alerts/alerts_screen.dart';
import 'features/alerts/alert_detail_screen.dart';
import 'features/map/map_screen.dart';
import 'features/map/room_sweep_checklist.dart';
import 'features/broadcast/broadcast_screen.dart';
import 'features/incident_log/log_screen.dart';
import 'models/alert.dart';

void main() {
  runApp(const ProviderScope(child: ResqnetStaffApp()));
}

final _router = GoRouter(
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
            return AlertDetailScreen(alert: alert);
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
      builder: (context, state) => const RoomSweepChecklistScreen(),
    ),
    GoRoute(
      path: '/broadcast',
      builder: (context, state) => const BroadcastScreen(),
    ),
    GoRoute(
      path: '/logs',
      builder: (context, state) => const IncidentLogScreen(),
    ),
  ],
);

class ResqnetStaffApp extends StatelessWidget {
  const ResqnetStaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RESQNET Staff',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF8F9FF), // background
        primaryColor: const Color(0xFF2A5A9C), // primary
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2A5A9C),
          secondary: Color(0xFFB6171E), // secondary
          tertiary: Color(0xFF1E6816), // tertiary
          surface: Color(0xFFFFFFFF), // surface-container-lowest
          error: Color(0xFFBA1A1A),
          onSurface: Color(0xFF021D34),
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.light().textTheme,
        ).apply(
          bodyColor: const Color(0xFF021D34), // on-background
          displayColor: const Color(0xFF021D34), // on-background
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF021D34),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      routerConfig: _router,
    );
  }
}

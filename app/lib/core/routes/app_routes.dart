import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/alerts/screens/alerts_dashboard.dart';
import '../../features/alerts/screens/alert_details_screen.dart';
import '../../features/map/screens/indoor_map_screen.dart';
import '../../features/map/screens/room_sweep_checklist_screen.dart';
import '../../features/broadcast/screens/broadcast_screen.dart';
import '../../features/incident_log/screens/incident_log_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String alertDetails = '/alertDetails';
  static const String map = '/map';
  static const String checklist = '/checklist';
  static const String broadcast = '/broadcast';
  static const String logs = '/logs';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      dashboard: (context) => const AlertsDashboard(),
      map: (context) => const IndoorMapScreen(),
      checklist: (context) => const RoomSweepChecklistScreen(),
      broadcast: (context) => const BroadcastScreen(),
      logs: (context) => const IncidentLogScreen(),
    };
  }

  // Handle dynamic routing with arguments for deep links
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == alertDetails) {
      final String alertId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => AlertDetailsScreen(alertId: alertId),
      );
    }
    return null; // Fallback to routes map or default
  }
}

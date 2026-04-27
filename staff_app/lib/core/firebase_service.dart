import 'dart:async';
import '../models/alert.dart';

/// Mock service for LAN-based pub/sub real-time synchronization.
/// Replaces Firebase for offline/LAN constraints.
class LANPubSubService {
  final _alertsController = StreamController<List<Alert>>.broadcast();
  List<Alert> _currentAlerts = [Alert.mock()];

  LANPubSubService() {
    // Simulate incoming alert every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _currentAlerts.add(
        Alert(
          id: 'ALT-\${DateTime.now().millisecondsSinceEpoch}',
          type: EmergencyType.medical,
          location: 'Pool Area',
          severity: AlertSeverity.high,
          timestamp: DateTime.now(),
          description: 'Guest reported slip and fall.',
        ),
      );
      _alertsController.add(List.from(_currentAlerts));
    });
  }

  Stream<List<Alert>> get alertsStream async* {
    yield _currentAlerts;
    yield* _alertsController.stream;
  }

  void acknowledgeAlert(String id) {
    final index = _currentAlerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _currentAlerts[index];
      _currentAlerts[index] = Alert(
        id: old.id,
        type: old.type,
        location: old.location,
        severity: old.severity,
        timestamp: old.timestamp,
        description: old.description,
        status: AlertStatus.investigating,
      );
      _alertsController.add(List.from(_currentAlerts));
    }
  }
  
  void dispose() {
    _alertsController.close();
  }
}

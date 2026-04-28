enum AlertSeverity { low, medium, high, critical }
enum EmergencyType { fire, medical, earthquake, security, unknown }
enum AlertStatus { active, investigating, resolved }

class Alert {
  final String id;
  final EmergencyType type;
  final String location; // e.g., 'Room 304' or 'Lobby'
  final AlertSeverity severity;
  final DateTime timestamp;
  final String description;
  final AlertStatus status;

  Alert({
    required this.id,
    required this.type,
    required this.location,
    required this.severity,
    required this.timestamp,
    required this.description,
    this.status = AlertStatus.active,
  });

  factory Alert.mock() {
    return Alert(
      id: 'ALT-101',
      type: EmergencyType.fire,
      location: 'Floor 3, Kitchen',
      severity: AlertSeverity.critical,
      timestamp: DateTime.now(),
      description: 'Smoke detector activated in the 3rd-floor auxiliary kitchen.',
    );
  }
}

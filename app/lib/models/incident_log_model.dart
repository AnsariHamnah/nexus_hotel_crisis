class IncidentLogModel {
  final String id;
  final String alertId;
  final String action; // e.g., 'DISPATCHED_POLICE', 'ROOM_CLEARED', 'ELEVATOR_LOCKED'
  final String performedBy; // Staff ID or 'SYSTEM_AI'
  final String details;
  final DateTime timestamp;

  IncidentLogModel({
    required this.id,
    required this.alertId,
    required this.action,
    required this.performedBy,
    required this.details,
    required this.timestamp,
  });

  factory IncidentLogModel.fromMap(Map<String, dynamic> data, String documentId) {
    return IncidentLogModel(
      id: documentId,
      alertId: data['alertId'] ?? '',
      action: data['action'] ?? '',
      performedBy: data['performedBy'] ?? 'UNKNOWN',
      details: data['details'] ?? '',
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alertId': alertId,
      'action': action,
      'performedBy': performedBy,
      'details': details,
      'timestamp': timestamp,
    };
  }
}

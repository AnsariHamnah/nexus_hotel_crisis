class AlertCategory {
  static const String fire = 'Fire';
  static const String medical = 'Medical';
  static const String harassment = 'Harassment / Assault';
  static const String childMissing = 'Child Missing';
  static const String securityThreat = 'Security Threat';
  static const String flood = 'Flood';
  static const String elevator = 'Elevator Emergency';
  static const String gasLeak = 'Gas Leak';
  static const String silentSOS = 'Silent SOS';
}

class EscalationStatus {
  static const String pending = 'PENDING_AI_TRIAGE';
  static const String awaitingApproval = 'AWAITING_MANAGER_APPROVAL';
  static const String dispatched = 'DISPATCHED_TO_AUTHORITIES';
  static const String resolved = 'RESOLVED';
}

class AlertModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String severity;
  final String escalationStatus;
  final bool managerApproved;
  final Map<String, bool> dispatchFlow; 
  final DateTime timestamp;
  
  // AI Enriched Fields
  final String? instructions;
  final String? recommendedAction;
  final String? location;
  final bool? evacuateFloor;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.escalationStatus,
    required this.managerApproved,
    required this.dispatchFlow,
    required this.timestamp,
    this.instructions,
    this.recommendedAction,
    this.location,
    this.evacuateFloor,
  });

  factory AlertModel.fromMap(Map<String, dynamic> data, String documentId) {
    // Prioritize Gemini fields if they exist
    final aiCategory = data['crisis_class'];
    final aiInstructions = data['instructions_for_staff'];
    final aiAction = data['recommended_action'];
    final aiLocation = data['location'];
    final aiSeverity = data['severity'];

    return AlertModel(
      id: documentId,
      title: aiAction ?? data['title'] ?? 'Emergency Alert',
      description: data['description'] ?? '',
      category: aiCategory ?? data['category'] ?? 'General',
      severity: (aiSeverity ?? data['severity'] ?? 'LOW').toString().toUpperCase(),
      escalationStatus: data['escalationStatus'] ?? EscalationStatus.pending,
      managerApproved: data['managerApproved'] ?? false,
      dispatchFlow: Map<String, bool>.from(data['dispatchFlow'] ?? {}),
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
      instructions: aiInstructions,
      recommendedAction: aiAction,
      location: aiLocation,
      evacuateFloor: data['evacuate_floor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'escalationStatus': escalationStatus,
      'managerApproved': managerApproved,
      'dispatchFlow': dispatchFlow,
      'timestamp': timestamp,
      'instructions_for_staff': instructions,
      'recommended_action': recommendedAction,
      'location': location,
      'evacuate_floor': evacuateFloor,
    };
  }
}


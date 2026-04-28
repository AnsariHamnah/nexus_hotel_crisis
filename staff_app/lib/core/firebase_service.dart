import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert.dart';

/// Production-safe Firebase service for real-time alerts.
/// Replaces mock LANPubSubService with Firestore /alerts stream.
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Real-time stream from Firestore /alerts collection
  Stream<List<Alert>> get alertsStream {
    return _firestore
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return Alert(
          id: doc.id,
          type: _parseEmergencyType(data['type']),
          location: data['location'] ?? 'Unknown Location',
          severity: _parseSeverity(data['severity']),
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          description: data['description'] ?? 'No description available',
          status: _parseStatus(data['status']),
        );
      }).toList();
    });
  }

  /// Update alert status when staff acknowledges alert
  Future<void> acknowledgeAlert(String id) async {
    await _firestore.collection('alerts').doc(id).update({
      'status': 'investigating',
    });
  }

  EmergencyType _parseEmergencyType(String? value) {
    switch (value?.toLowerCase()) {
      case 'fire':
        return EmergencyType.fire;
      case 'security':
        return EmergencyType.security;
      case 'medical':
      default:
        return EmergencyType.medical;
    }
  }

  AlertSeverity _parseSeverity(String? value) {
    switch (value?.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'high':
        return AlertSeverity.high;
      case 'medium':
        return AlertSeverity.medium;
      case 'low':
      default:
        return AlertSeverity.low;
    }
  }

  AlertStatus _parseStatus(String? value) {
    switch (value?.toLowerCase()) {
      case 'investigating':
        return AlertStatus.investigating;
      case 'resolved':
        return AlertStatus.resolved;
      case 'new':
      default:
        return AlertStatus.newAlert;
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/alert_model.dart';

/// This service manages the escalation flow from the Flutter app.
/// It works in tandem with the Firebase Cloud Function `onCriticalAlert()`.
class AlertEscalationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Initial creation of an alert. 
  // Note: No direct emergency calling from frontend. The backend handles dispatch.
  Future<void> createAlert(AlertModel alert) async {
    try {
      // The Cloud Function will trigger 'onCreate' for this collection
      // and use Gemini to classify severity and update 'escalationStatus'.
      await _firestore.collection('alerts').add(alert.toMap());
    } catch (e) {
      throw Exception('Failed to create alert: $e');
    }
  }

  // 2. Manager Approval Flow
  // A manager reviews the AI-triaged alert and approves escalation
  Future<void> approveEscalation(String alertId, Map<String, bool> dispatchOptions) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'managerApproved': true,
        'escalationStatus': EscalationStatus.awaitingApproval, 
        // A Cloud Function `onUpdate` will detect managerApproved == true
        // and handle the final transition to 'DISPATCHED_TO_AUTHORITIES'
        'dispatchFlow': dispatchOptions,
      });
    } catch (e) {
      throw Exception('Failed to approve escalation: $e');
    }
  }

  // 3. Mark as Resolved
  Future<void> resolveAlert(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'escalationStatus': EscalationStatus.resolved,
      });
    } catch (e) {
      throw Exception('Failed to resolve alert: $e');
    }
  }
}

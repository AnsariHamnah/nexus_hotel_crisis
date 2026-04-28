import 'package:cloud_firestore/cloud_firestore.dart';

/// GeminiService - Now fetches AI-generated summaries from Cloud Functions output in Firestore.
/// This ensures Gemini is called server-side only.
class GeminiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> generateIncidentReport(String alertId) async {
    try {
      // 1. Fetch the most recent resolved incident if alertId is 'mock_data'
      // Otherwise fetch the specific alert.
      QuerySnapshot snapshot;
      if (alertId == 'mock_data') {
        snapshot = await _firestore
            .collection('alerts')
            .where('escalationStatus', isEqualTo: 'RESOLVED')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
      } else {
        final doc = await _firestore.collection('alerts').doc(alertId).get();
        if (doc.exists && doc.data()?['ai_summary_formatted'] != null) {
          return doc.data()?['ai_summary_formatted'];
        }
        return "AI Summary is still being generated or is unavailable for this incident.";
      }

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return data['ai_summary_formatted'] ?? "AI Summary available soon...";
      }

      return "NO_RECENT_INCIDENTS_FOUND_FOR_SUMMARY";
    } catch (e) {
      return "ERROR FETCHING AI SUMMARY: $e";
    }
  }
}

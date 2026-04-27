import 'dart:async';

/// Mock service for Gemini API integration with offline fallback.
class GeminiService {
  Future<String> generateIncidentReport(String incidentData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real scenario, this would call Gemini.
    // Here we simulate an AI-generated timeline based on the offline fallback.
    return '''
# AI Incident Report
**Timestamp:** \${DateTime.now().toIso8601String()}

## Summary
A fire incident was reported on Floor 3, Auxiliary Kitchen. Staff successfully contained the area and evacuated 14 guests.

## Timeline
- **00:00** - Smoke detector triggered. Alert generated.
- **00:02** - Staff "Alex Johnson" acknowledged the alert.
- **00:05** - Security sweep initiated on Floor 3.
- **00:15** - Floor 3 confirmed fully evacuated.

## AI Insights
- **Response Time:** Excellent (under 3 minutes to acknowledgment).
- **Risk Assessment:** High risk managed effectively. Structural damage unlikely but ventilation required.
''';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/alert_model.dart';
import '../../../models/floor_plan_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// DemoSimulationService
/// Used strictly for generating perfect, predictable data during presentations.
/// DO NOT leave active in production builds.
class DemoSimulationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Simulate Fire Emergency (Full Escalation)
  Future<void> simulateFireEmergency() async {
    final alert = AlertModel(
      id: '',
      title: 'Smoke Detector Triggered - Room 412',
      description: 'AI Triage: Multiple smoke sensors tripped in South Wing. High probability of active fire. \n\nACTION: Immediate evacuation of Floor 4 and 5. Elevators locked. Do NOT use North Stairwell.',
      category: AlertCategory.fire,
      severity: 'CRITICAL',
      escalationStatus: EscalationStatus.pending,
      managerApproved: false,
      dispatchFlow: {},
      timestamp: DateTime.now(),
    );
    
    await _firestore.collection('alerts').add(alert.toMap());
    _injectAuditLog('SYSTEM_AI', 'Detected Fire in Room 412. Gemini Triage complete.');
  }

  // 2. Simulate Child Missing
  Future<void> simulateChildMissing() async {
    final alert = AlertModel(
      id: '',
      title: 'Code Amber - Pool Area',
      description: 'AI Triage: 6-year-old boy, red shirt. \n\nACTION: Security to lock down all perimeter exits. Housekeeping to monitor corridors. Manager to review pool camera feeds immediately.',
      category: AlertCategory.childMissing,
      severity: 'HIGH',
      escalationStatus: EscalationStatus.pending,
      managerApproved: false,
      dispatchFlow: {},
      timestamp: DateTime.now(),
    );
    
    await _firestore.collection('alerts').add(alert.toMap());
    _injectAuditLog('GUEST_APP', 'Guest reported missing child at Main Pool.');
  }

  // 3. Simulate Staff Positions (Puts markers on the map)
  Future<void> simulateStaffPositions(String floorId) async {
    // Inject fake staff location data for map rendering
    await _firestore.collection('staff').doc('demo_sec_1').set({
      'name': 'John (Security)',
      'role': 'security',
      'isActive': true,
      'lastKnownLocation': {'floorId': floorId, 'x': 150.0, 'y': 200.0},
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.collection('staff').doc('demo_hk_1').set({
      'name': 'Maria (Housekeeping)',
      'role': 'housekeeping',
      'isActive': true,
      'lastKnownLocation': {'floorId': floorId, 'x': 300.0, 'y': 450.0},
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  
  Future<void> _injectAuditLog(String user, String details) async {
     await _firestore.collection('audit_logs_global').add({
        'action': 'SIMULATION_EVENT',
        'details': details,
        'performedBy': user,
        'timestamp': FieldValue.serverTimestamp(),
      });
  }
}

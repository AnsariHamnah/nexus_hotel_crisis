import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ResponderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Generate Secure Access Link for external Responders (Police/Fire)
  // This avoids giving them permanent auth credentials.
  Future<String> generateSecureResponderLink(String alertId) async {
    try {
      // Create a secure short-lived token/pin
      final String securePin = (Random().nextInt(900000) + 100000).toString(); // 6 digit pin
      
      // Store in a dedicated 'responder_access' collection with a TTL
      await _firestore.collection('responder_access').doc(securePin).set({
        'alertId': alertId,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(hours: 4)), // Auto-expires in 4 hours
        'status': 'ACTIVE',
      });

      // In production, this link would be sent via Twilio to the dispatch center
      // return 'https://resqnet-responder.web.app/auth?pin=$securePin';
      return securePin;
    } catch (e) {
      throw Exception('Failed to generate responder link: $e');
    }
  }

  // 2. Incident Timeline Logging
  Future<void> logIncidentAction({
    required String alertId,
    required String action,
    required String details,
    String? performedByUid,
  }) async {
    try {
      final uid = performedByUid ?? FirebaseAuth.instance.currentUser?.uid ?? 'SYSTEM';
      
      await _firestore
          .collection('alerts')
          .doc(alertId)
          .collection('audit_logs')
          .add({
        'alertId': alertId,
        'action': action,
        'performedBy': uid,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Audit log failed: $e');
    }
  }

  // 3. Update Room Clearance Tracking
  Future<void> updateRoomClearance({
    required String hotelId,
    required String roomId,
    required String clearanceStatus,
    required int occupantsCount,
  }) async {
    try {
      await _firestore
          .collection('hotels')
          .doc(hotelId)
          .collection('rooms')
          .doc(roomId)
          .update({
        'clearanceStatus': clearanceStatus,
        'occupantsCount': occupantsCount,
        'lastClearanceUpdate': FieldValue.serverTimestamp(),
      });

      // Log the sweep
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'UNKNOWN';
      await _firestore.collection('audit_logs_global').add({
        'action': 'ROOM_SWEEP',
        'details': 'Room $roomId marked as $clearanceStatus with $occupantsCount occupants.',
        'performedBy': uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update room clearance: $e');
    }
  }
}

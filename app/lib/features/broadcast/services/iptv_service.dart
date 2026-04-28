import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/floor_plan_model.dart';

/// Prepares the architecture for the IPTV Evacuation Overlay.
/// When a critical alert is approved by the manager, this service 
/// updates the global hotel metadata to trigger the IPTV overlay
/// across all smart TVs in the hotel.
class IptvService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Trigger evacuation overlay on all screens
  Future<void> triggerEvacuationOverlay(String hotelId, String evacuationRouteUrl) async {
    try {
      await _firestore.collection('hotels').doc(hotelId).set({
        'evacuationMetadata': {
          'isEvacuating': true,
          'overlayImageUrl': evacuationRouteUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'CRITICAL_ALERT_OVERLAY',
        }
      }, SetOptions(merge: true));
      // The IoT / IPTV backend system will listen to changes on the 
      // `/hotels/{hotelId}` document and push the overlay to the screens.
    } catch (e) {
      throw Exception('Failed to trigger IPTV overlay: $e');
    }
  }

  // Push a highly specific dynamic route calculated by the RoutingEngine
  // directly to a specific room's TV overlay.
  Future<void> pushRoomSpecificRoute({
    required String hotelId,
    required String roomId,
    required List<GraphNode> safePath,
  }) async {
    try {
      // The path points are passed to the frontend of the smart TV to render
      final pathCoordinates = safePath.map((node) => {'x': node.x, 'y': node.y}).toList();
      
      await _firestore
          .collection('hotels')
          .doc(hotelId)
          .collection('rooms')
          .doc(roomId)
          .update({
            'activeEvacuationRoute': pathCoordinates,
            'evacuationStatus': 'ROUTED_SAFEST_PATH',
            'lastRouteUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to push room-specific route: $e');
    }
  }

  // Disable the overlay when the emergency is resolved
  Future<void> disableOverlay(String hotelId) async {
    try {
      await _firestore.collection('hotels').doc(hotelId).update({
        'evacuationMetadata': {
          'isEvacuating': false,
          'overlayImageUrl': null,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'CLEAR',
        }
      });
    } catch (e) {
      throw Exception('Failed to disable IPTV overlay: $e');
    }
  }
}


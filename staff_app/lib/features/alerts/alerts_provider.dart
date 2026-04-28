import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/firebase_service.dart';
import '../../models/alert.dart';

/// Firebase Service Provider
/// Replaces old mock LANPubSubService completely
final firebaseServiceProvider =
    Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Real-time Firestore Alerts Stream
/// Source:
/// FirebaseFirestore.instance.collection('alerts')
final alertsStreamProvider =
    StreamProvider<List<Alert>>((ref) {
  final service = ref.watch(firebaseServiceProvider);

  return service.alertsStream;
});

/// Optional: Single Alert Provider for Detail Screen
final selectedAlertProvider =
    StateProvider<Alert?>((ref) => null);
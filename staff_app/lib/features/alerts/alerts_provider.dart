import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/firebase_service.dart';
import '../../models/alert.dart';

// Provides the singleton instance of the LANPubSubService
final lanPubSubProvider = Provider<LANPubSubService>((ref) {
  final service = LANPubSubService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Stream of alerts from the LAN PubSub service
final alertsStreamProvider = StreamProvider<List<Alert>>((ref) {
  final service = ref.watch(lanPubSubProvider);
  return service.alertsStream;
});

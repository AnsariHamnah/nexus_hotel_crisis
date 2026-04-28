import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/alert_service.dart';
import '../../../models/alert_model.dart';

/// Provider for the production AlertService
final alertServiceProvider = Provider<AlertService>((ref) {
  return AlertService();
});

/// StreamProvider for real-time alerts from Firestore
final alertsStreamProvider = StreamProvider<List<AlertModel>>((ref) {
  final service = ref.watch(alertServiceProvider);
  return service.alertsStream;
});

/// Provider for a single alert based on ID
final alertDetailProvider = StreamProvider.family<AlertModel?, String>((ref, id) {
  final service = ref.watch(alertServiceProvider);
  return service.getAlertStream(id);
});

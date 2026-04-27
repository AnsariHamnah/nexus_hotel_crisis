import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/maps_service.dart';

final mapsServiceProvider = Provider<MapsService>((ref) {
  final service = MapsService();
  ref.onDispose(() => service.dispose());
  return service;
});

final locationStreamProvider = StreamProvider<Coordinate>((ref) {
  final service = ref.watch(mapsServiceProvider);
  return service.locationStream;
});

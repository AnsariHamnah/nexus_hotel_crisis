import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/map_service.dart';
import '../../../models/staff_model.dart';
import '../../../models/floor_plan_model.dart';
import '../../../models/room_model.dart';

final mapServiceProvider = Provider<MapService>((ref) {
  return MapService();
});

final floorPlansProvider = StreamProvider.family<List<FloorPlanModel>, String>((ref, hotelId) {
  final service = ref.watch(mapServiceProvider);
  return service.getFloorPlans(hotelId);
});

final staffLocationsProvider = StreamProvider<List<StaffModel>>((ref) {
  final service = ref.watch(mapServiceProvider);
  return service.getStaffLocations();
});

final roomsProvider = StreamProvider.family<List<RoomModel>, String>((ref, hotelId) {
  final service = ref.watch(mapServiceProvider);
  return service.getRooms(hotelId);
});

import 'floor_plan_model.dart';

class HotelModel {
  final String id;
  final String name;
  final String address;
  final List<FloorPlanModel> floorPlans;
  final Map<String, dynamic> evacuationMetadata;

  HotelModel({
    required this.id,
    required this.name,
    required this.address,
    this.floorPlans = const [],
    this.evacuationMetadata = const {},
  });

  factory HotelModel.fromMap(Map<String, dynamic> data, String documentId) {
    return HotelModel(
      id: documentId,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      // Note: floorPlans would typically be a subcollection in Firestore /hotels/{hotelId}/floorPlans
      // This is kept here for data modeling, but should be queried separately.
      evacuationMetadata: data['evacuationMetadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'evacuationMetadata': evacuationMetadata,
    };
  }
}

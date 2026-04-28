class StaffModel {
  final String id;
  final String name;
  final String role;
  final String department;
  final bool isActive;
  final Map<String, dynamic>? lastKnownLocation; // e.g., {'x': 120.5, 'y': 340.2, 'floorId': 'floor1'}
  final DateTime? lastLocationUpdate;

  StaffModel({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    this.isActive = false,
    this.lastKnownLocation,
    this.lastLocationUpdate,
  });

  factory StaffModel.fromMap(Map<String, dynamic> data, String documentId) {
    return StaffModel(
      id: documentId,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      department: data['department'] ?? '',
      isActive: data['isActive'] ?? false,
      lastKnownLocation: data['lastKnownLocation'],
      lastLocationUpdate: data['lastLocationUpdate']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'department': department,
      'isActive': isActive,
      'lastKnownLocation': lastKnownLocation,
      'lastLocationUpdate': lastLocationUpdate,
    };
  }
}


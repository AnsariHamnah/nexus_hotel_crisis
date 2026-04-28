class RoomClearanceStatus {
  static const String unknown = 'UNKNOWN';
  static const String safe = 'SAFE';
  static const String needsHelp = 'NEEDS_HELP';
  static const String evacuated = 'EVACUATED';
  static const String medicalRequired = 'MEDICAL_REQUIRED';
}

class RoomModel {
  final String id;
  final String roomNumber;
  final String status;
  final String floor;
  
  // Emergency Sweep & Clearance Tracking
  final String clearanceStatus;
  final int occupantsCount;
  final DateTime? lastClearanceUpdate;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.status,
    required this.floor,
    this.clearanceStatus = RoomClearanceStatus.unknown,
    this.occupantsCount = 0,
    this.lastClearanceUpdate,
  });

  factory RoomModel.fromMap(Map<String, dynamic> data, String documentId) {
    return RoomModel(
      id: documentId,
      roomNumber: data['roomNumber'] ?? '',
      status: data['status'] ?? 'UNKNOWN',
      floor: data['floor'] ?? '',
      clearanceStatus: data['clearanceStatus'] ?? RoomClearanceStatus.unknown,
      occupantsCount: data['occupantsCount'] ?? 0,
      lastClearanceUpdate: data['lastClearanceUpdate']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomNumber': roomNumber,
      'status': status,
      'floor': floor,
      'clearanceStatus': clearanceStatus,
      'occupantsCount': occupantsCount,
      'lastClearanceUpdate': lastClearanceUpdate,
    };
  }
}


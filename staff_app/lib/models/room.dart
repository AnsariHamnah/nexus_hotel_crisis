enum RoomStatus { safe, needsHelp, unknown }

class Room {
  final String id;
  final String roomNumber;
  final String floor;
  RoomStatus status;
  final bool hasGuests;

  Room({
    required this.id,
    required this.roomNumber,
    required this.floor,
    this.status = RoomStatus.unknown,
    this.hasGuests = true,
  });
}

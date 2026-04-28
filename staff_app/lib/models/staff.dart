enum Role { staff, security, admin }
enum StaffStatus { available, busy, responding, offline }

class Staff {
  final String id;
  final String name;
  final Role role;
  final StaffStatus status;
  final String? assignedZone;
  final String? currentLocation; // e.g. "x,y coordinates" or "Lobby"

  Staff({
    required this.id,
    required this.name,
    required this.role,
    this.status = StaffStatus.available,
    this.assignedZone,
    this.currentLocation,
  });

  factory Staff.mock() {
    return Staff(
      id: 'STF-001',
      name: 'Alex Johnson',
      role: Role.security,
      status: StaffStatus.responding,
      assignedZone: 'Floor 3',
      currentLocation: 'Stairwell B',
    );
  }
}

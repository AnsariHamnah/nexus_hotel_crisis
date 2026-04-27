import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/room.dart';

final roomListProvider = StateProvider<List<Room>>((ref) {
  return [
    Room(id: 'r1', roomNumber: '401', floor: '4'),
    Room(id: 'r2', roomNumber: '402', floor: '4'),
    Room(id: 'r3', roomNumber: '403', floor: '4'),
  ];
});

class RoomSweepChecklistScreen extends ConsumerWidget {
  const RoomSweepChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Color(0xFF021D34), width: 2)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF021D34)),
          onPressed: () {},
        ),
        title: Text(
          'RESQNET',
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF021D34),
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
            fontSize: 24,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2), // red-50
                  border: Border.all(color: const Color(0xFFDC2626), width: 1), // red-600
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.radar, color: Color(0xFFDC2626), size: 14),
                    const SizedBox(width: 4),
                    Text('SWEEP MODE', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626))),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Progress Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SWEEP PROGRESS', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('45%', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF021D34), width: 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.45,
                    child: Container(
                      color: const Color(0xFF2563EB), // blue-600
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Color(0xFF021D34), width: 2)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(height: 2, color: const Color(0xFF021D34)),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF021D34), width: 2),
                      boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(4, 4))],
                    ),
                    child: TextField(
                      style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontWeight: FontWeight.bold, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'ENTER ROOM NUMBER...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // slate-400
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // slate-100
                    border: Border.all(color: const Color(0xFF021D34), width: 2),
                    boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(4, 4))],
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: Color(0xFF021D34)),
                )
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return _buildRoomCard(ref, room, index, rooms);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildRoomCard(WidgetRef ref, Room room, int index, List<Room> rooms) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF021D34), width: 2),
        boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(8, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.door_front_door, color: Color(0xFF021D34), size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ROOM \${room.roomNumber}',
                          style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        Text(
                          'STATUS: \${room.status.name.toUpperCase()}',
                          style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 2, color: const Color(0xFF021D34)),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _updateRoomStatus(ref, rooms, index, RoomStatus.safe),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: room.status == RoomStatus.safe ? const Color(0xFF2563EB) : Colors.transparent,
                    child: Center(
                      child: Text(
                        'MARK CLEAR',
                        style: GoogleFonts.spaceGrotesk(color: room.status == RoomStatus.safe ? Colors.white : const Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: 2, height: 64, color: const Color(0xFF021D34)),
              Expanded(
                child: InkWell(
                  onTap: () => _updateRoomStatus(ref, rooms, index, RoomStatus.needsHelp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: room.status == RoomStatus.needsHelp ? const Color(0xFFDC2626) : Colors.transparent,
                    child: Center(
                      child: Text(
                        'REPORT HAZARD',
                        style: GoogleFonts.spaceGrotesk(color: room.status == RoomStatus.needsHelp ? Colors.white : const Color(0xFFDC2626), fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _updateRoomStatus(WidgetRef ref, List<Room> rooms, int index, RoomStatus newStatus) {
    final newList = List<Room>.from(rooms);
    newList[index].status = newStatus;
    ref.read(roomListProvider.notifier).state = newList;
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFF021D34), width: 2)),
        boxShadow: [BoxShadow(color: Color(0x0D000000), offset: Offset(0, -4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.notifications, 'ALERTS', false, () => context.push('/alerts')),
          _navItem(Icons.map, 'MAP', false, () => context.push('/map')),
          _navItem(Icons.fact_check, 'SWEEP', true, () {}),
          _navItem(Icons.podcasts, 'BROADCAST', false, () => context.push('/broadcast')),
          _navItem(Icons.description, 'REPORT', false, () => context.push('/logs')),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    final activeColor = const Color(0xFF2563EB); // blue-600
    final inactiveColor = const Color(0xFF94A3B8); // slate-400
    final color = isActive ? activeColor : inactiveColor;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent, // blue-50
            border: Border(top: BorderSide(color: isActive ? activeColor : Colors.transparent, width: 4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

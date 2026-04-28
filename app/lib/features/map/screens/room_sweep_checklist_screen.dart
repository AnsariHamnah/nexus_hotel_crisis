import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/maps_provider.dart';
import '../services/map_service.dart';
import '../../../widgets/main_scaffold.dart';
import '../../../models/room_model.dart';

class RoomSweepChecklistScreen extends ConsumerWidget {
  final String hotelId;

  const RoomSweepChecklistScreen({super.key, this.hotelId = 'default_hotel_id'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider(hotelId));
    const textOnSurface = Color(0xFF021D34);

    return MainScaffold(
      currentIndex: 2,
      title: 'TACTICAL_SWEEP',
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2A5A9C))),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (roomsList) {
          // Injection for Demo if empty
          final rooms = roomsList.isNotEmpty ? roomsList : [
            RoomModel(id: 'r1', roomNumber: '101', status: 'OCCUPIED', floor: '1', clearanceStatus: RoomClearanceStatus.safe),
            RoomModel(id: 'r2', roomNumber: '102', status: 'OCCUPIED', floor: '1', clearanceStatus: RoomClearanceStatus.unknown),
            RoomModel(id: 'r3', roomNumber: '103', status: 'EMPTY', floor: '1', clearanceStatus: RoomClearanceStatus.unknown),
            RoomModel(id: 'r4', roomNumber: '104', status: 'OCCUPIED', floor: '1', clearanceStatus: RoomClearanceStatus.needsHelp),
            RoomModel(id: 'r5', roomNumber: '105', status: 'OCCUPIED', floor: '1', clearanceStatus: RoomClearanceStatus.unknown),
          ];

          final clearedCount = rooms.where((r) => r.clearanceStatus == RoomClearanceStatus.safe).length;
          final progress = rooms.isEmpty ? 0.0 : clearedCount / rooms.length;

          return Column(
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
                        Text('SWEEP PROGRESS', style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${(progress * 100).toInt()}%', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 24)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 24,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: textOnSurface, width: 2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          color: const Color(0xFF2563EB),
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: textOnSurface, width: 2)),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(height: 2, color: textOnSurface),

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
                          border: Border.all(color: textOnSurface, width: 2),
                          boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(4, 4))],
                        ),
                        child: TextField(
                          style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontWeight: FontWeight.bold, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'ENTER ROOM NUMBER...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        border: Border.all(color: textOnSurface, width: 2),
                        boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(4, 4))],
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: textOnSurface),
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
                    return _buildRoomCard(context, ref, room);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, WidgetRef ref, RoomModel room) {
    const textOnSurface = Color(0xFF021D34);
    final isSafe = room.clearanceStatus == RoomClearanceStatus.safe;
    final isDanger = room.clearanceStatus == RoomClearanceStatus.needsHelp;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: textOnSurface, width: 2),
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
                    const Icon(Icons.door_front_door, color: textOnSurface, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ROOM ${room.roomNumber}',
                          style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        Text(
                          'STATUS: ${room.clearanceStatus.replaceAll('_', ' ')}',
                          style: GoogleFonts.spaceGrotesk(color: isDanger ? const Color(0xFFDC2626) : const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 2, color: textOnSurface),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => MapService().updateRoomClearanceStatus(hotelId, room.id, RoomClearanceStatus.safe),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: isSafe ? const Color(0xFF2563EB) : Colors.transparent,
                    child: Center(
                      child: Text(
                        'MARK CLEAR',
                        style: GoogleFonts.spaceGrotesk(color: isSafe ? Colors.white : const Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: 2, height: 64, color: textOnSurface),
              Expanded(
                child: InkWell(
                  onTap: () => MapService().updateRoomClearanceStatus(hotelId, room.id, RoomClearanceStatus.needsHelp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: isDanger ? const Color(0xFFDC2626) : Colors.transparent,
                    child: Center(
                      child: Text(
                        'REPORT HAZARD',
                        style: GoogleFonts.spaceGrotesk(color: isDanger ? Colors.white : const Color(0xFFDC2626), fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
}

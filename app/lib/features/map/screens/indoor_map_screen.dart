import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/maps_provider.dart';
import '../../../widgets/main_scaffold.dart';
import '../../../models/staff_model.dart';
import '../../../models/floor_plan_model.dart';

class IndoorMapScreen extends ConsumerWidget {
  final String hotelId;

  const IndoorMapScreen({super.key, this.hotelId = 'default_hotel_id'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffLocationsProvider);
    final floorPlansAsync = ref.watch(floorPlansProvider(hotelId));

    return MainScaffold(
      currentIndex: 1,
      title: 'TACTICAL_MAP',
      body: Stack(
        children: [
          // Simulated grid background for aesthetic
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: GridPainter(color: const Color(0xFF021D34))),
            ),
          ),
          
          Column(
            children: [
              // Floor Selector Strip
              floorPlansAsync.when(
                data: (plans) => Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: plans.map((p) => _buildFloorButton(p.floorName, plans.indexOf(p) == 0)).toList(),
                  ),
                ),
                loading: () => const SizedBox(height: 72, child: Center(child: CircularProgressIndicator())),
                error: (e, s) => Container(height: 72, color: Colors.white, child: Center(child: Text('Error loading floors'))),
              ),
              Container(height: 2, color: const Color(0xFF021D34)),

              // Map Container
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF021D34), width: 2),
                      boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(8, 8))],
                    ),
                    child: floorPlansAsync.when(
                      data: (plans) {
                        final currentFloor = plans.isNotEmpty 
                            ? plans.first 
                            : FloorPlanModel(
                                id: 'demo',
                                floorName: 'FLOOR 01 (DEMO)',
                                imageUrl: '',
                                exitCoordinates: [],
                                stairwellCoordinates: [],
                                assemblyPoints: [],
                              );
                        
                        return Stack(
                          children: [
                            // 1. Base Map Layer (Floor Plan Image if exists, else grid)
                            Positioned.fill(
                              child: currentFloor.imageUrl.isNotEmpty
                                  ? Image.network(currentFloor.imageUrl, fit: BoxFit.contain)
                                  : Container(
                                      color: const Color(0xFFF1F5F9),
                                      child: CustomPaint(
                                        painter: GridPainter(color: const Color(0xFFCBD5E1)),
                                      ),
                                    ),
                            ),

                            if (plans.isEmpty) 
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.map_outlined, size: 48, color: const Color(0xFF94A3B8).withOpacity(0.5)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'SIMULATED TACTICAL VIEW',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: const Color(0xFF94A3B8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // 2. Staff Markers
                            staffAsync.when(
                              data: (staffList) {
                                // If no real staff, add demo staff for visual
                                final displayStaff = staffList.isNotEmpty ? staffList : [
                                  StaffModel(id: 's1', name: 'Security Alpha', role: 'Security', isActive: true, lastKnownLocation: {'x': 100.0, 'y': 150.0}),
                                  StaffModel(id: 's2', name: 'Medic Bravo', role: 'Medical', isActive: true, lastKnownLocation: {'x': 250.0, 'y': 300.0}),
                                ];

                                return Stack(
                                  children: displayStaff.map((staff) {
                                    if (staff.lastKnownLocation == null) return const SizedBox.shrink();
                                    final double x = (staff.lastKnownLocation!['x'] ?? 0.0).toDouble();
                                    final double y = (staff.lastKnownLocation!['y'] ?? 0.0).toDouble();

                                    return Positioned(
                                      left: x,
                                      top: y,
                                      child: _buildStaffMarker(staff),
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (e, s) => const SizedBox.shrink(),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('MAP_LOAD_ERROR')),
                    ),
                  ),
                ),
              ),
              
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: const RoundedRectangleBorder(),
                          side: const BorderSide(color: Color(0xFFDC2626), width: 2),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('ZONE EVACUATION INITIATED', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                              backgroundColor: const Color(0xFFDC2626),
                            ),
                          );
                        },
                        child: Text('EVACUATE ZONE', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF021D34),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: const RoundedRectangleBorder(side: BorderSide(color: Color(0xFF021D34), width: 2)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('FACILITY LOCKDOWN ACTIVE', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                              backgroundColor: const Color(0xFF021D34),
                            ),
                          );
                        },
                        child: Text('LOCKDOWN', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloorButton(String label, bool active) {
    const activeColor = Color(0xFF2563EB);
    const textOnSurface = Color(0xFF021D34);
    
    return Container(
      width: 64,
      height: 48,
      decoration: BoxDecoration(
        color: active ? activeColor : Colors.white,
        border: Border.all(color: textOnSurface, width: 2),
        boxShadow: active ? [const BoxShadow(color: textOnSurface, offset: Offset(4, 4))] : [],
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: active ? Colors.white : textOnSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffMarker(StaffModel staff) {
    final color = staff.role.toLowerCase() == 'security' ? const Color(0xFF2563EB) : const Color(0xFF059669);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF021D34), width: 2),
            boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(2, 2))],
          ),
          child: Text(
            staff.name.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 4)],
          ),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 32) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 32) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

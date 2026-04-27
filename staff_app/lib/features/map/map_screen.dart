import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'maps_provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationStreamProvider);

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
                  color: const Color(0xFFEFF6FF), // blue-50
                  border: Border.all(color: const Color(0xFF2563EB), width: 1), // blue-600
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('LIVE RADAR', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // Simulated grid background
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: GridPainter(color: const Color(0xFF021D34))),
            ),
          ),
          
          Column(
            children: [
              // Floor Selector Strip
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFloorButton('L04', false),
                    _buildFloorButton('L03', false),
                    _buildFloorButton('L02', true),
                    _buildFloorButton('L01', false),
                  ],
                ),
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
                    child: locationAsync.when(
                      data: (coord) {
                        return Stack(
                          children: [
                            // Inner Grid
                            Positioned.fill(
                              child: CustomPaint(painter: GridPainter(color: const Color(0xFFE2E8F0))), // slate-200
                            ),

                            // Hazard zone
                            Positioned(
                              top: 60,
                              left: 60,
                              child: Container(
                                width: 140,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2), // red-50
                                  border: Border.all(color: const Color(0xFFDC2626), width: 2), // red-600
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.local_fire_department, color: Color(0xFFDC2626)),
                                    const SizedBox(height: 4),
                                    Text('THERMAL_ANOMALY', style: GoogleFonts.spaceGrotesk(color: const Color(0xFFDC2626), fontSize: 10, fontWeight: FontWeight.bold)),
                                    Text('AVOID ZONE', style: GoogleFonts.spaceGrotesk(color: const Color(0xFFDC2626), fontSize: 8, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Staff location blip
                            Positioned(
                              left: coord.x + 100,
                              top: coord.y + 150,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: const Color(0xFF021D34), width: 2),
                                      boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(2, 2))],
                                    ),
                                    child: Text(
                                      'YOU (SQUAD_A)',
                                      style: GoogleFonts.spaceGrotesk(color: const Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB), // blue-600
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: const [BoxShadow(color: Color(0x402563EB), blurRadius: 8, spreadRadius: 4)],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2A5A9C))),
                      error: (e, s) => Center(child: Text('Map Error: $e', style: const TextStyle(color: Color(0xFFB6171E)))),
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
                        onPressed: () {},
                        child: Text('EVACUATE ZONE', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: const RoundedRectangleBorder(side: BorderSide(color: Color(0xFF021D34), width: 2)),
                        ),
                        onPressed: () {},
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
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildFloorButton(String label, bool active) {
    final activeColor = const Color(0xFF2563EB); // blue-600
    final textOnSurface = const Color(0xFF021D34);
    
    return Container(
      width: 64,
      height: 48,
      decoration: BoxDecoration(
        color: active ? activeColor : Colors.white,
        border: Border.all(color: textOnSurface, width: 2),
        boxShadow: active ? [BoxShadow(color: textOnSurface, offset: const Offset(4, 4))] : [],
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
          _navItem(Icons.map, 'MAP', true, () {}),
          _navItem(Icons.fact_check, 'SWEEP', false, () => context.push('/checklist')),
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

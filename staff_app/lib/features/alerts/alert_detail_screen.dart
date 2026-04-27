import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/alert.dart';
import 'alerts_provider.dart';

class AlertDetailScreen extends ConsumerWidget {
  final Alert alert;

  const AlertDetailScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color getSeverityColor(AlertSeverity severity) {
      switch (severity) {
        case AlertSeverity.critical: return const Color(0xFFB6171E); // Secondary
        case AlertSeverity.high: return const Color(0xFFDA3433); // Secondary container
        case AlertSeverity.medium: return const Color(0xFF4673B7); // Primary container
        case AlertSeverity.low: return const Color(0xFF2A5A9C); // Primary
      }
    }

    final sColor = getSeverityColor(alert.severity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Color(0xFF021D34), width: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF021D34)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'INCIDENT_DETAILS',
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF021D34),
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            fontSize: 20,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                alert.id,
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF021D34), width: 2),
                boxShadow: [BoxShadow(color: sColor, offset: const Offset(8, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: sColor, size: 32),
                          const SizedBox(width: 12),
                          Text(
                            alert.type.name.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        color: sColor,
                        child: Text(
                          alert.severity.name.toUpperCase() + ' PRIORITY',
                          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildInfoItem('LOCATION', alert.location, Icons.location_on, const Color(0xFF2A5A9C))),
                      Container(width: 2, height: 40, color: const Color(0xFFE2E8F0)),
                      Expanded(child: _buildInfoItem('T-MINUS', '00:14:22', Icons.timer, const Color(0xFFB6171E))),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Description
            Text('INCIDENT LOG', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF021D34), width: 2),
                boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(4, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.description,
                    style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Actions
            Text('COMMAND DIRECTIVES', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A5A9C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                  side: const BorderSide(color: Color(0xFF021D34), width: 2),
                ),
                icon: const Icon(Icons.my_location),
                label: Text('LOCATE ON TACTICAL MAP', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                onPressed: () {
                  ref.read(lanPubSubProvider).acknowledgeAlert(alert.id);
                  context.push('/map');
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB6171E),
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                  side: const BorderSide(color: Color(0xFFB6171E), width: 2),
                ),
                icon: const Icon(Icons.checklist),
                label: Text('INITIATE SWEEP', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                onPressed: () {
                  context.push('/checklist');
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF021D34),
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                  side: const BorderSide(color: Color(0xFF021D34), width: 2),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: Text('MARK AS RESOLVED', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                onPressed: () {
                  // Resolve alert
                  context.pop();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            Text(value, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        )
      ],
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
          _navItem(Icons.notifications, 'ALERTS', true, () {}),
          _navItem(Icons.map, 'MAP', false, () => context.push('/map')),
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

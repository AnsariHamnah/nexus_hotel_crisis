import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/alert_model.dart';
import '../services/alert_escalation_service.dart';
import '../providers/alerts_provider.dart';

class AlertDetailsScreen extends ConsumerWidget {
  final String alertId;

  const AlertDetailsScreen({super.key, required this.alertId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertAsync = ref.watch(alertDetailProvider(alertId));

    return alertAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (alert) {
        if (alert == null) {
          return const Scaffold(body: Center(child: Text('Alert not found or resolved.')));
        }

        return _AlertDetailsContent(alert: alert);
      },
    );
  }
}

class _AlertDetailsContent extends ConsumerWidget {
  final AlertModel alert;

  const _AlertDetailsContent({required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sColor = alert.severity == 'CRITICAL' ? const Color(0xFFB6171E) : const Color(0xFF2A5A9C);
    const textOnSurface = Color(0xFF021D34);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: textOnSurface, width: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textOnSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'INCIDENT_DETAILS',
          style: GoogleFonts.spaceGrotesk(
            color: textOnSurface,
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
                alert.id.substring(0, 8).toUpperCase(),
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
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: textOnSurface, width: 2),
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
                            alert.category.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        color: sColor,
                        child: Text(
                          '${alert.severity} PRIORITY',
                          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    alert.title,
                    style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildInfoItem('LOCATION', alert.location ?? 'UNKNOWN', Icons.location_on, const Color(0xFFB6171E))),
                      Container(width: 2, height: 40, color: const Color(0xFFE2E8F0)),
                      Expanded(child: _buildInfoItem('STATUS', alert.escalationStatus.replaceAll('_', ' '), Icons.info_outline, const Color(0xFF2A5A9C))),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // AI TRIAGE PANEL
            Text('AI TRIAGE & DIRECTIVES', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Light blue background for AI
                border: Border.all(color: textOnSurface, width: 2),
                boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(4, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 20),
                      const SizedBox(width: 8),
                      Text('INTELLIGENCE FEED', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alert.instructions ?? alert.description,
                    style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                  if (alert.evacuateFloor == true) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFFFEF2F2),
                      child: Row(
                        children: [
                          const Icon(Icons.exit_to_app, color: Color(0xFFB6171E), size: 20),
                          const SizedBox(width: 8),
                          Text('EVACUATION RECOMMENDED', style: GoogleFonts.spaceGrotesk(color: const Color(0xFFB6171E), fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 48),

            // ESCALATION CONTROLS (Manager Only/Conditional)
            Text('COMMAND DIRECTIVES', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            
            if (alert.escalationStatus == EscalationStatus.pending) ...[
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB6171E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(),
                    side: const BorderSide(color: Color(0xFF021D34), width: 2),
                  ),
                  icon: const Icon(Icons.gavel),
                  label: Text('APPROVE ESCALATION', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  onPressed: () async {
                    await AlertEscalationService().approveEscalation(alert.id, {'police': true, 'ambulance': true});
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

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
                  // Navigate to map (Task 5: Wiring navigation)
                  // For now, we use a simple navigation to the map screen
                  // In a real app, we might pass the location to highlight
                  // IndexedStack index 1 is Map
                  // However, MainScaffold handles navigation. 
                  // We can pop and change the index via a provider if needed, 
                  // or just navigate to a new instance of IndoorMapScreen.
                  Navigator.pushReplacementNamed(context, '/map'); 
                },
              ),
            ),
            const SizedBox(height: 16),
            
            if (alert.escalationStatus != EscalationStatus.resolved)
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
                  onPressed: () async {
                    await AlertEscalationService().resolveAlert(alert.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Text(value, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ],
          ),
        )
      ],
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}

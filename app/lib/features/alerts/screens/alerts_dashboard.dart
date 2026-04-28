import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/alert_model.dart';
import '../providers/alerts_provider.dart';
import 'alert_details_screen.dart';
import '../../../widgets/main_scaffold.dart';

class AlertsDashboard extends ConsumerWidget {
  const AlertsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsStreamProvider);

    return MainScaffold(
      currentIndex: 0,
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2A5A9C))),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (alerts) {
          if (alerts.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _buildAlertCard(context, alert);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, size: 64, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          Text(
            'SYSTEM NOMINAL',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF021D34),
              letterSpacing: 2,
            ),
          ),
          Text(
            'NO ACTIVE EMERGENCIES DETECTED',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: const Color(0xFF64748B),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertModel alert) {
    final sColor = alert.severity == 'CRITICAL' ? const Color(0xFFB6171E) : const Color(0xFF2A5A9C);
    const textOnSurface = Color(0xFF021D34);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: textOnSurface, width: 2),
        boxShadow: [BoxShadow(color: sColor, offset: const Offset(8, 8))],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlertDetailsScreen(alertId: alert.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            alert.severity == 'CRITICAL' ? Icons.error : Icons.warning_amber_rounded,
                            color: sColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            alert.category.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              color: sColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatTime(alert.timestamp),
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alert.title,
                    style: GoogleFonts.spaceGrotesk(
                      color: textOnSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF64748B),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                border: Border(top: BorderSide(color: textOnSurface, width: 1.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sync, size: 14, color: Color(0xFF2A5A9C)),
                      const SizedBox(width: 4),
                      Text(
                        alert.escalationStatus.replaceAll('_', ' '),
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF2A5A9C),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, size: 16, color: textOnSurface),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

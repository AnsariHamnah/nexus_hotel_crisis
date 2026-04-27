import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/alert.dart';
import 'alerts_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsStreamProvider);

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
                  color: const Color(0xFFF1F5F9), // slate-100
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('CENTRAL COMMAND', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
              ),
            ),
          )
        ],
      ),
      body: alertsAsync.when(
        data: (alerts) {
          return Column(
            children: [
              // Persistent Critical Banner
              if (alerts.isNotEmpty)
                Container(
                  color: const Color(0xFFB6171E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'ACTIVE EMERGENCY PROTOCOL ENGAGED',
                            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: Colors.white.withValues(alpha: 0.2),
                        child: Text('\${alerts.length} INCIDENTS', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricsGrid(alerts),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'Incident Queue',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFF021D34),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (alerts.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text('SYSTEM NORMAL', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF39822E), fontSize: 24, fontWeight: FontWeight.bold)),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) => _buildAlertCard(context, alerts[index]),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2A5A9C))),
        error: (error, stack) => Center(child: Text('ERROR: $error', style: const TextStyle(color: Color(0xFFB6171E)))),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFB6171E),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF021D34), width: 2),
        ),
        child: const Icon(Icons.add_alert),
      ),
    );
  }

  Widget _buildMetricsGrid(List<Alert> alerts) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('TOTAL ACTIVE', '\${alerts.length}', const Color(0xFFE4EFFF), const Color(0xFF2A5A9C)),
        _buildMetricCard('FIRE ALARMS', '04', const Color(0xFFFFDAD6), const Color(0xFFBA1A1A)),
        _buildMetricCard('MEDICAL', '06', const Color(0xFFDAE9FF), const Color(0xFFB6171E)),
        _buildMetricCard('RESOLVED (24H)', '142', const Color(0xFFA7F692), const Color(0xFF1E6816)),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color bgColor, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: const Color(0xFF021D34), width: 2),
        boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(4, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF424750),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Alert alert) {
    Color getSeverityColor(AlertSeverity severity) {
      switch (severity) {
        case AlertSeverity.critical: return const Color(0xFFB6171E); // Secondary
        case AlertSeverity.high: return const Color(0xFFDA3433); // Secondary container
        case AlertSeverity.medium: return const Color(0xFF4673B7); // Primary container
        case AlertSeverity.low: return const Color(0xFF2A5A9C); // Primary
      }
    }
    
    String getAlertLabel(AlertSeverity severity) {
      switch (severity) {
        case AlertSeverity.critical: return 'FIRE ALERT';
        case AlertSeverity.high: return 'MEDICAL EMERGENCY';
        case AlertSeverity.medium: return 'SECURITY ALERT';
        case AlertSeverity.low: return 'INFO';
      }
    }

    final sColor = getSeverityColor(alert.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF021D34), width: 2),
        boxShadow: [
          BoxShadow(
            color: sColor,
            offset: const Offset(8, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: sColor),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: sColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              getAlertLabel(alert.severity),
                              style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            alert.description.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('02:14m', style: GoogleFonts.spaceGrotesk(color: sColor, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('ELAPSED', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF737782), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LOCATION', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(alert.location, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('STATUS', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(alert.status.name.toUpperCase(), style: GoogleFonts.spaceGrotesk(color: sColor, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A5A9C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(side: BorderSide(color: Color(0xFF021D34), width: 2)),
                        ),
                        onPressed: () {},
                        child: Text('DISPATCH SQUAD', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF021D34),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(),
                          side: const BorderSide(color: Color(0xFF021D34), width: 2),
                        ),
                        onPressed: () => context.push('/alerts/\${alert.id}', extra: alert),
                        child: Text('DETAILS', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
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

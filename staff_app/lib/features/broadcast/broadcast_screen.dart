import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _triggerBroadcast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('TRANSMITTING MESSAGE...', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2563EB), // blue-600
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFFDCFCE7), // green-100
                  border: Border.all(color: const Color(0xFF16A34A), width: 1), // green-600
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.rss_feed, color: Color(0xFF16A34A), size: 14),
                    const SizedBox(width: 4),
                    Text('COMMS LINK', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A))),
                  ],
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
            // QUICK BROADCAST TEMPLATES
            Text('QUICK BROADCAST TEMPLATES', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            _buildQuickAlertBtn('Fire Alert', 'Initiate Evacuation Protocol Alpha', Icons.local_fire_department, const Color(0xFFB6171E)),
            const SizedBox(height: 16),
            _buildQuickAlertBtn('Medical Emergency', 'First responders to staging area', Icons.medical_services, const Color(0xFF2A5A9C)),
            const SizedBox(height: 16),
            _buildQuickAlertBtn('Security Threat', 'Lockdown procedures in effect', Icons.security, const Color(0xFF021D34)),
            
            const SizedBox(height: 48),

            // CUSTOM BROADCAST
            Text('CUSTOM BROADCAST', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF021D34), width: 2),
                boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(4, 4))],
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 6,
                style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'ENTER BROADCAST MESSAGE...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // slate-400
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(24),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A5A9C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: const RoundedRectangleBorder(),
                      side: const BorderSide(color: Color(0xFF021D34), width: 2),
                    ),
                    icon: const Icon(Icons.podcasts),
                    label: Text('BROADCAST TO ALL', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    onPressed: _triggerBroadcast,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF021D34),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: const RoundedRectangleBorder(),
                      side: const BorderSide(color: Color(0xFF021D34), width: 2),
                    ),
                    onPressed: () {},
                    child: Text('SELECT ZONES', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildQuickAlertBtn(String title, String subtitle, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        _messageController.text = subtitle;
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: const Color(0xFF021D34), width: 2),
          boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(8, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    Text(subtitle.toUpperCase(), style: GoogleFonts.spaceGrotesk(color: Colors.white.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ],
                ),
              ],
            ),
          ],
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
          _navItem(Icons.map, 'MAP', false, () => context.push('/map')),
          _navItem(Icons.fact_check, 'SWEEP', false, () => context.push('/checklist')),
          _navItem(Icons.podcasts, 'BROADCAST', true, () {}),
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

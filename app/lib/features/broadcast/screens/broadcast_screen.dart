import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/iptv_service.dart';
import '../../../widgets/main_scaffold.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final TextEditingController _messageController = TextEditingController();
  final IptvService _iptvService = IptvService();
  bool _isTransmitting = false;

  void _triggerBroadcast() async {
    if (_messageController.text.isEmpty) return;

    setState(() => _isTransmitting = true);

    try {
      // Trigger the IPTV overlay for the hotel (using a default ID for demo)
      await _iptvService.triggerEvacuationOverlay('default_hotel_id', 'https://firebasestorage.googleapis.com/v0/b/nexus-hotel-crisis.appspot.com/o/evacuation_overlays%2Fdefault.png?alt=media');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TRANSMISSION SUCCESSFUL', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: const Color(0xFF059669), // green-600
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TRANSMISSION FAILED: $e', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: const Color(0xFFDC2626), // red-600
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTransmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const textOnSurface = Color(0xFF021D34);

    return MainScaffold(
      currentIndex: 3,
      title: 'EMERGENCY_COMMS',
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
                border: Border.all(color: textOnSurface, width: 2),
                boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(4, 4))],
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 6,
                style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontSize: 16, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: 'ENTER BROADCAST MESSAGE...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(24),
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
                    icon: _isTransmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.podcasts),
                    label: Text(_isTransmitting ? 'TRANSMITTING...' : 'BROADCAST TO ALL', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    onPressed: _isTransmitting ? null : _triggerBroadcast,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: textOnSurface,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: const RoundedRectangleBorder(),
                      side: const BorderSide(color: Color(0xFF021D34), width: 2),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ZONE SELECTION ACTIVE - BROADCASTING TO ALL FOR DEMO', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                          backgroundColor: const Color(0xFF2A5A9C),
                        ),
                      );
                    },
                    child: Text('SELECT ZONES', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAlertBtn(String title, String subtitle, IconData icon, Color color) {
    const textOnSurface = Color(0xFF021D34);
    return InkWell(
      onTap: () {
        setState(() {
          _messageController.text = subtitle;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: textOnSurface, width: 2),
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
                    Text(subtitle.toUpperCase(), style: GoogleFonts.spaceGrotesk(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/gemini_service.dart';

class IncidentLogScreen extends StatefulWidget {
  const IncidentLogScreen({super.key});

  @override
  State<IncidentLogScreen> createState() => _IncidentLogScreenState();
}

class _IncidentLogScreenState extends State<IncidentLogScreen> {
  final _geminiService = GeminiService();
  String? _reportContent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() async {
    try {
      final report = await _geminiService.generateIncidentReport('mock_data');
      if (mounted) {
        setState(() {
          _reportContent = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reportContent = 'ERROR GENERATING REPORT:\n$e';
          _isLoading = false;
        });
      }
    }
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
                  color: const Color(0xFFEFF6FF), // blue-50
                  border: Border.all(color: const Color(0xFF2563EB), width: 1), // blue-600
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.download, color: Color(0xFF2563EB), size: 14),
                    const SizedBox(width: 4),
                    Text('EXPORT REPORT', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2A5A9C)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI AFTER-ACTION REPORT', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF021D34), width: 2),
                      boxShadow: const [BoxShadow(color: Color(0xFF021D34), offset: Offset(8, 8))],
                    ),
                    child: Text(
                      _reportContent ?? 'NO DATA',
                      style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontSize: 16, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(context),
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
          _navItem(Icons.podcasts, 'BROADCAST', false, () => context.push('/broadcast')),
          _navItem(Icons.description, 'REPORT', true, () {}),
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

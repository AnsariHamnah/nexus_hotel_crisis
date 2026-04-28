import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/auth/services/auth_service.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.body,
    this.title = 'RESQNET',
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    const textOnSurface = Color(0xFF021D34);
    final authService = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: textOnSurface, width: 2)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: textOnSurface),
          onPressed: () {},
        ),
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            color: textOnSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: textOnSurface),
            onPressed: () async => await authService.logout(),
          ),
        ],
      ),
      body: body,
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
          _navItem(context, Icons.notifications, 'ALERTS', currentIndex == 0, '/dashboard'),
          _navItem(context, Icons.map, 'MAP', currentIndex == 1, '/map'),
          _navItem(context, Icons.fact_check, 'SWEEP', currentIndex == 2, '/checklist'),
          _navItem(context, Icons.podcasts, 'BROADCAST', currentIndex == 3, '/broadcast'),
          _navItem(context, Icons.description, 'REPORT', currentIndex == 4, '/logs'),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool isActive, String route) {
    const activeColor = Color(0xFF2563EB); // blue-600
    const inactiveColor = Color(0xFF94A3B8); // slate-400
    final color = isActive ? activeColor : inactiveColor;
    
    return Expanded(
      child: InkWell(
        onTap: isActive
            ? null
            : () {
                Navigator.pushReplacementNamed(context, route);
              },
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent, 
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

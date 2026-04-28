import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _pinController = TextEditingController();
  final _idController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String _selectedRole = 'Staff';

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).login(_pinController.text);
      if (mounted) context.go('/alerts');
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Invalid credentials. Try 1234.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const textOnSurface = Color(0xFF021D34);
    const primary = Color(0xFF2A5A9C);
    const outline = Color(0xFF737782);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative Grid Background
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(painter: GridPainter(color: textOnSurface)),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'RESQNET',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: textOnSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MISSION CRITICAL RESPONSE NETWORK',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: outline,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Main Form Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: textOnSurface, width: 2),
                          boxShadow: const [
                            BoxShadow(color: textOnSurface, offset: Offset(8, 8))
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -32,
                              left: -32,
                              right: -32,
                              child: Container(height: 4, color: primary),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Role Selection
                                Text('OPERATIONAL ROLE', style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(child: _buildRoleButton('Staff', Icons.person)),
                                    const SizedBox(width: 4),
                                    Expanded(child: _buildRoleButton('Security', Icons.admin_panel_settings)),
                                    const SizedBox(width: 4),
                                    Expanded(child: _buildRoleButton('Admin', Icons.security)),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Inputs
                                Text('PERSONNEL ID', style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                const SizedBox(height: 4),
                                _buildInput(_idController, 'RN-XXXX-000', Icons.fingerprint, false),
                                const SizedBox(height: 16),
                                Text('ACCESS KEY', style: GoogleFonts.spaceGrotesk(color: textOnSurface, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                const SizedBox(height: 4),
                                _buildInput(_pinController, '••••••••••••', Icons.vpn_key, true),
                                if (_error != null) ...[
                                  const SizedBox(height: 8),
                                  Text(_error!, style: GoogleFonts.spaceGrotesk(color: const Color(0xFFBA1A1A), fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                                const SizedBox(height: 32),

                                // Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: const RoundedRectangleBorder(),
                                    ),
                                    onPressed: _isLoading ? null : _handleLogin,
                                    child: _isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'INITIALIZE SESSION',
                                                style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.bolt, size: 20),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(color: Color(0xFF39822E), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              Text('SYSTEM: NOMINAL', style: GoogleFonts.spaceGrotesk(color: outline, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            ],
                          ),
                          Text('NODE: US-CENTRAL-01', style: GoogleFonts.spaceGrotesk(color: outline, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1)),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      // Emergency Override
                      InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFB6171E), width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(width: 8, height: 64, color: const Color(0xFFB6171E)), // simplified emergency stripe
                              const SizedBox(width: 16),
                              const Icon(Icons.emergency_share, color: Color(0xFFB6171E)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('EMERGENCY OVERRIDE', style: GoogleFonts.spaceGrotesk(color: const Color(0xFFB6171E), fontSize: 14, fontWeight: FontWeight.bold)),
                                    Text('LEVEL 4 CLEARANCE REQUIRED', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF930010), fontSize: 9, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Color(0xFFB6171E)),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(String role, IconData icon) {
    final isSelected = _selectedRole == role;
    final primary = const Color(0xFF2A5A9C);
    final textOnSurface = const Color(0xFF021D34);
    
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4673B7) : Colors.transparent,
          border: Border.all(color: isSelected ? primary : textOnSurface, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: textOnSurface, offset: const Offset(4, 4))] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : primary),
            Text(
              role.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : textOnSurface),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, bool obscure) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF021D34), width: 2),
        color: Colors.white,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, color: const Color(0xFF737782), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: GoogleFonts.spaceGrotesk(color: const Color(0xFF021D34), fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF737782)),
                border: InputBorder.none,
              ),
            ),
          )
        ],
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
    for (double i = 0; i < size.width; i += 24) {
      for (double j = 0; j < size.height; j += 24) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

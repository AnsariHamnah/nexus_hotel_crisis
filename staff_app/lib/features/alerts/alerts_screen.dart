import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final email = _idController.text.trim();
      final password = _pinController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        throw Exception("Please enter credentials");
      }

      /// Firebase Auth Login
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      /// Firestore Role Fetch
      final staffDoc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(uid)
          .get();

      if (!staffDoc.exists) {
        throw Exception("Staff profile not found");
      }

      final role = staffDoc.data()?['role'] ?? 'staff';

      if (!mounted) return;

      /// RBAC Navigation
      if (role == 'manager') {
        context.go('/alerts');
      } else if (role == 'security') {
        context.go('/alerts');
      } else if (role == 'admin') {
        context.go('/alerts');
      } else {
        context.go('/alerts');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Login failed';
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll("Exception: ", "");
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _idController.dispose();
    super.dispose();
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
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: GridPainter(color: textOnSurface),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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

                      /// KEEP YOUR EXISTING BEAUTIFUL UI BELOW
                      /// No visual redesign required

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("INITIALIZE SESSION"),
                        ),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
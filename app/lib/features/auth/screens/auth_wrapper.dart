import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import '../../alerts/screens/alerts_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1. Check Auth State connection
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // 2. If User is logged in, re-validate their profile in Firestore
        if (authSnapshot.hasData && authSnapshot.data != null) {
          final authService = AuthService();
          final String uid = authSnapshot.data!.uid;

          return FutureBuilder(
            future: authService.validateSession(uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                // Show Splash Screen while fetching RBAC data
                return const SplashScreen();
              }

              if (profileSnapshot.hasError || !profileSnapshot.hasData) {
                // Invalid session (e.g., deactivated account, changed role) -> Route to Login
                // The validateSession method handles logging them out.
                return const LoginScreen();
              }

              // Valid session -> Route to Dashboard
              return const AlertsDashboard();
            },
          );
        }

        // 3. User is not logged in -> Route to Login
        return const LoginScreen();
      },
    );
  }
}

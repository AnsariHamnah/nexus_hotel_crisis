import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/staff.dart';

final authProvider = StateNotifierProvider<AuthNotifier, Staff?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<Staff?> {
  AuthNotifier() : super(null);

  Future<void> login(String pin) async {
    // Simulate local auth check
    await Future.delayed(const Duration(milliseconds: 500));
    if (pin == '1234') {
      state = Staff.mock(); // Login successful as mock user
    } else {
      throw Exception('Invalid PIN');
    }
  }

  void logout() {
    state = null;
  }
}

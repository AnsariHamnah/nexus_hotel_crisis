import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/staff_model.dart';
import '../../../core/services/notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> supportedRoles = [
    'security',
    'housekeeping',
    'manager',
    'admin'
  ];

  // Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with Email/Password & Validate RBAC
  Future<StaffModel?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception("Authentication failed.");
      }

      String uid = userCredential.user!.uid;
      DocumentSnapshot staffDoc = await _firestore.collection('staff').doc(uid).get();

      if (!staffDoc.exists) {
        await logout(uid);
        throw Exception("Staff profile not found. Access denied.");
      }

      StaffModel staffProfile = StaffModel.fromMap(
        staffDoc.data() as Map<String, dynamic>,
        staffDoc.id,
      );

      if (!staffProfile.isActive) {
        await logout(uid);
        throw Exception("Account is deactivated. Contact administrator.");
      }

      if (!supportedRoles.contains(staffProfile.role.toLowerCase())) {
        await logout(uid);
        throw Exception("Role not recognized or unsupported. Access denied.");
      }

      // FCM Integration: Register device token on successful login
      await NotificationService().registerDeviceToken(uid);

      return staffProfile;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "An authentication error occurred.");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Validate Existing Session (Run on App Launch)
  Future<StaffModel?> validateSession(String uid) async {
    try {
      DocumentSnapshot staffDoc = await _firestore.collection('staff').doc(uid).get();

      if (!staffDoc.exists) {
        await logout(uid);
        throw Exception("Staff profile not found. Access denied.");
      }

      StaffModel staffProfile = StaffModel.fromMap(
        staffDoc.data() as Map<String, dynamic>,
        staffDoc.id,
      );

      if (!staffProfile.isActive) {
        await logout(uid);
        throw Exception("Account is deactivated. Contact administrator.");
      }

      if (!supportedRoles.contains(staffProfile.role.toLowerCase())) {
        await logout(uid);
        throw Exception("Role not recognized or unsupported. Access denied.");
      }

      // FCM Integration: Re-register token to keep it fresh
      await NotificationService().registerDeviceToken(uid);

      return staffProfile;
    } catch (e) {
      await logout(uid);
      rethrow;
    }
  }

  // Logout functionality
  Future<void> logout([String? uid]) async {
    String? targetUid = uid ?? _auth.currentUser?.uid;
    if (targetUid != null) {
      await NotificationService().removeDeviceToken(targetUid);
    }
    await _auth.signOut();
  }
}
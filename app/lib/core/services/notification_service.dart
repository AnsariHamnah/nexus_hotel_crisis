import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // We avoid initializing here to keep the background handler lightweight, 
  // relying on standard FCM payload data processing.
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // A global navigator key to handle deep-linking from notifications
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    // 1. Request Permissions (Silent/Vibration priority UX)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true, // Required for iOS critical alerts
      provisional: false,
      sound: true, // We will control actual sound via payload to keep it silent when needed
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized || 
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted notification permission');
      
      // 2. Setup Foreground Message Handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      // 3. Setup App Open from Notification Handler (Background/Terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(message);
      });

      // 4. Setup Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 5. Handle initial message if app was terminated and opened by tap
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Register the device token to Firestore for Cloud Function routing
  Future<void> registerDeviceToken(String uid) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        // Save token to staff document (or a subcollection for multiple devices)
        await _firestore.collection('staff').doc(uid).update({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print('FCM Token registered: $token');
      }

      // Listen for token refreshes
      _fcm.onTokenRefresh.listen((newToken) async {
        await _firestore.collection('staff').doc(uid).update({
          'fcmTokens': FieldValue.arrayUnion([newToken]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Failed to register FCM token: $e');
    }
  }

  // Remove the device token (called on logout)
  Future<void> removeDeviceToken(String uid) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _firestore.collection('staff').doc(uid).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
    } catch (e) {
      print('Failed to remove FCM token: $e');
    }
  }

  // Handle Foreground Notifications silently (no loud popups, just UI sync or silent vibration)
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.messageId}');
    // Since the app is open, we let the StreamBuilder in AlertsDashboard handle the UI update natively.
    // We could trigger a local silent vibration here if required.
  }

  // Handle routing when a notification is tapped
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification Tapped! Data: ${message.data}');
    
    // Deep linking to exact alert details screen
    if (message.data.containsKey('alertId')) {
      final String alertId = message.data['alertId'];
      
      // Navigate using the global key
      if (navigatorKey.currentState != null) {
        // Pop any dialogs and push to details
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
        // Note: For a real deep link push, we might need a custom route or a named route with arguments.
        // Assuming we update app_routes to handle this, or push material route directly:
        // navigatorKey.currentState!.pushNamed('/alertDetails', arguments: alertId);
        
        // For simplicity with existing architecture, we can push the explicit Widget if imported,
        // but since this is a core service, we rely on a named route implementation.
        navigatorKey.currentState!.pushNamed('/alertDetails', arguments: alertId);
      }
    }
  }
}

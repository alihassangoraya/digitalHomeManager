import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permissions (important for iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Get token, store in Firestore under current user for targeting
    final token = await _messaging.getToken();
    final user = FirebaseAuth.instance.currentUser;
    if (token != null && user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.collection('tokens').doc(token).set({'token': token});
    }

    // Background and foreground notification handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // For in-app notification, you could show a dialog/snackbar
      // print('Foreground message received: ${message.notification?.title}');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notification here if needed
  // print('Background message: ${message.notification?.title}');
}

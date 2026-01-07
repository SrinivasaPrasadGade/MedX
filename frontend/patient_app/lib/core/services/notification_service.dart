import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'firebase_options.dart'; // generated via flutterfire configure (Missing)

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

class NotificationService {
  FirebaseMessaging? _fcm;

  Future<void> init() async {
    try {
      // Try to initialize Firebase
      // If we had the generated options, we would use them here:
      // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      
      // Without options, it looks for google-services.json on Android / plist on iOS.
      await Firebase.initializeApp(); 
      _fcm = FirebaseMessaging.instance;

      // 1. Request Permission
      NotificationSettings settings = await _fcm!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
        
        // 2. Get Token
        try {
           String? token = await _fcm!.getToken();
           debugPrint("FCM Token: $token");
        } catch (e) {
           debugPrint("Error getting FCM token: $e");
        }

        // 3. Listen for foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          if (message.notification != null) {
            debugPrint('Title: ${message.notification?.title}, Body: ${message.notification?.body}');
          }
        });
        
      } else {
        debugPrint('User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint("Firebase Init Failed (Likely missing google-services.json): $e");
      debugPrint("Notification Service will operate in MOCK mode.");
    }
  }

  Future<void> showNotification({required int id, required String title, required String body}) async {
    // Usually uses FlutterLocalNotificationsPlugin to show foreground notification
    debugPrint("--------------------------------------------------");
    debugPrint("[MOCK NOTIFICATION] ID: $id");
    debugPrint("Title: $title");
    debugPrint("Body: $body");
    debugPrint("--------------------------------------------------");
  }
}


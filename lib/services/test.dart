// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:kioski/feature/data/models/dataModels/ChatItemDataModel.dart';
// import 'package:kioski/feature/presentation/controller/chatCtrl.dart';
// import 'package:kioski/services/prefrences/prefrences.dart';
// import 'package:logger/logger.dart';
// import '../../firebase_options.dart';
//
// class FirebaseServices {
//   static final _chatCtrl = ChatCtrl.find;
//   static String? fcmToken;
//   static late FirebaseMessaging _messaging;
//   static late BuildContext _context;
//
//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Importance Notifications',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.high,
//     playSound: true,
//   );
//
//   static Future<void> init(BuildContext context) async {
//     _context = context;
//     WidgetsFlutterBinding.ensureInitialized();
//
//     if (Platform.isIOS) {
//       if (Firebase.apps.isEmpty) {
//         await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//       }
//     } else {
//       await Firebase.initializeApp();
//     }
//
//     _messaging = FirebaseMessaging.instance;
//
//     final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     final initSettings = InitializationSettings(android: androidSettings);
//
//     await _flutterLocalNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationClick,
//     );
//   }
//
//   static Future<void> requestAndFetchToken() async {
//     final permissionGranted = await _requestPermissions();
//     if (permissionGranted) {
//       await _messaging.deleteToken(); // Optional: for fresh token
//       fcmToken = await _messaging.getToken();
//       if (fcmToken != null) {
//         Preferences.setFcmToken = fcmToken;
//         Logger().i('FCM Token: $fcmToken');
//       }
//     }
//   }
//
//   static Future<bool> _requestPermissions() async {
//     try {
//       final settings = await _messaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: true,
//       );
//
//       Logger().i('Notification permission: ${settings.authorizationStatus}');
//       if (settings.authorizationStatus == AuthorizationStatus.authorized ||
//           settings.authorizationStatus == AuthorizationStatus.provisional) {
//         if (Platform.isAndroid) {
//           await FirebaseMessaging.instance.setAutoInitEnabled(true);
//         }
//         return true;
//       }
//       return false;
//     } catch (e) {
//       Logger().e('Permission error: $e');
//       return false;
//     }
//   }
//
//   static Future<void> setupListeners() async {
//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(_channel);
//
//     await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       Logger().i('Foreground Message: ${message.toMap()}');
//       _showLocalNotification(message);
//
//       final data = {
//         "senderId": "664cae8f50f10f5db469631f",
//         "senderType": "user",
//         "recipientId": "664b66a3f4997da688aa4e88",
//         "isDeleted": false,
//         "type": "text",
//         "message": "${message.notification?.body ?? ''} ${message.sentTime?.toIso8601String()}",
//         "threadId": "664b66a3f4997da688aa4e88664cae8f50f10f5db469631f",
//         "_id": "667cfe227761ecc7aee422e3",
//         "timestamp": DateTime.now().toIso8601String(),
//         "__v": 0
//       };
//
//       final msg = ChatItemDataModel.fromJsonGetSingleChat(data);
//       _chatCtrl.getMessageListener(msg);
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       Logger().i('Notification Tapped (Background): ${message.toMap()}');
//       _handleNotificationClick(message);
//     });
//
//     final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       Logger().i('Notification Tapped (Terminated): ${initialMessage.toMap()}');
//       _handleNotificationClick(initialMessage);
//     }
//   }
//
//   static Future<void> _showLocalNotification(RemoteMessage message) async {
//     final title = message.notification?.title ?? message.data['title'];
//     final body = message.notification?.body ?? message.data['body'];
//
//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           _channel.id,
//           _channel.name,
//           channelDescription: _channel.description,
//           icon: '@mipmap/ic_launcher',
//         ),
//       ),
//       payload: 'chat', // You can pass JSON string too
//     );
//   }
//
//   static void _onNotificationClick(NotificationResponse response) {
//     Logger().i('Foreground Notification Tap: ${response.payload}');
//     // Navigate or trigger something
//     // Example: Get.to(() => ChatScreen());
//   }
//
//   static void _handleNotificationClick(RemoteMessage message) {
//     Logger().i('Handle Click: ${message.data}');
//     // You can navigate or use controller logic
//     if (message.data['type'] == 'chat') {
//       final msg = ChatItemDataModel.fromJsonGetSingleChat({...}); // Your parsing
//       _chatCtrl.getMessageListener(msg);
//     }
//   }
// }

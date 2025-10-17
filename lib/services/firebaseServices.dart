import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
import 'package:sep/feature/presentation/liveStreaming_screen/broad_cast_video.dart';
import 'package:sep/main.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

import '../feature/presentation/chatScreens/Messages_Screen.dart';
import '../feature/presentation/controller/agora_chat_ctrl.dart';
import '../firebase_options.dart';


class FirebaseServices{
  // static final _chatCtrl = ChatCtrl.find;
  static String? fcmToken;

  static late FirebaseMessaging _messaging;
  static late BuildContext _context;
  static Future<void> init(context) async{
    _context = context;
    // runZonedGuarded<Future<void>>(() async {
    //   WidgetsFlutterBinding.ensureInitialized();
    //   await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform,
    //   );
    //
    //   FlutterError.onError =
    //       FirebaseCrashlytics.instance.recordFlutterFatalError;
    // }, (error, stack) =>
    //     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));

    try{
      WidgetsFlutterBinding.ensureInitialized();
      // if(Platform.isAndroid){
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      // }

    }catch(e){
      AppUtils.log('here is firebase issuee.... $e');
    }

    return;
  }



  static listener() async{
  // if(!Platform.isAndroid){
  //   return;
  // }
    _messaging = FirebaseMessaging.instance;
  await _requestPermissions();
    _generateDeviceToken();
    _requestPermissions().then((value) {
    });


    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

  await _flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: _onNotificationClick,
  );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  await _generateDeviceToken();

  _notificationListeners();
  }


  static _generateDeviceToken() async{
    try{
      _messaging.getToken().then((value) {
        fcmToken = value;
        Preferences.fcmToken = fcmToken;
        AppUtils.log('token result ....... +$value');
      });
    }catch(e){
      print('token result ....... +exception:: $e');
    }

    // if(await _requestPermissions()){
    //   _messaging.getToken().then((value) {
    //     fcmToken = value;
    //     print('token result ....... +$value');
    //   });
    // }
  }

  static Map<String,dynamic>? _payloadData;

  static _notificationListeners(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{

      print('.........666666');

      // ChatCtrl.find.joinRecentChat();
      ChatCtrl.find.fireRecentChatEvent();

      Map<String,dynamic> notification = message.data;
      RemoteNotification? notification1 = message.notification;

      _payloadData = message.data;

      Logger().d(message.data);
      Logger().d(message.notification?.toMap());
      Logger().d(message.toMap());
      final screen = getCurrentScreen();
      if(screen is MessageScreen && message.data['chatId'] == ChatCtrl.find.singleChatId){
        return;
      }





      // I/flutter (23624): │ 🐛 {
      // I/flutter (23624): │ 🐛   "hostName": "Chandan Sharma",
      // I/flutter (23624): │ 🐛   "hostId": "686ca52d6d4732abc2612876",
      // I/flutter (23624): │ 🐛   "type": "LIVE_STARTED",
      // I/flutter (23624): │ 🐛   "roomId": "live_686ca52d6d4732abc2612876_1752139045513"
      // I/flutter (23624): │ 🐛 }



      // final msg = ChatItemDataModel.fromJsonGetSingleChat(data);
      // _chatCtrl.getMessageListener(msg);



      // {
      //   "senderId": null,
      //   "category": null,
      //   "collapseKey": "com.app.kioski",
      //   "contentAvailable": false,
      //   "data": {
      //     "payload": "{\"name\":\"buyer\",\"email\":\"bhd@gmail.com\",\"image\":\"Abcd.jpg\",\"mobileNumber\":\"+911212121212\"}",
      //     "body": "Peter parker!!",
      //     "type": "Chat messages",
      //     "title": "buyer Sends you a message"
      //   },
      //   "from": "220349326802",
      //   "messageId": "0:1720419729653704%e989679ae989679a",
      //   "messageType": null,
      //   "mutableContent": false,
      //   "notification": {
      //     "title": "buyer Sends you a message",
      //     "titleLocArgs": [],
      //     "titleLocKey": null,
      //     "body": "Peter parker!!",
      //     "bodyLocArgs": [],
      //     "bodyLocKey": null,
      //     "android": {
      // W/FirebaseMessaging(13065): Unable to log event: analytics library is missing
      //       "channelId": null,
      //       "clickAction": null,
      //       "color": null,
      //       "count": null,
      //       "imageUrl": null,
      //       "link": null,
      //       "priority": 0,
      //       "smallIcon": null,
      //       "sound": null,
      //       "ticker": null,
      //       "tag": null,
      //       "visibility": 0
      //     },
      //     "apple": null,
      //     "web": null
      //   },
      //   "sentTime": 1720419729645,
      //   "threadId": null,
      //   "ttl": 2419200
      // }




      // Logger().d(message.notification?.body);

      if (message.notification != null ) {
        _flutterLocalNotificationsPlugin.show(
            1,
            message.notification?.title,
            message.notification?.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                // icon: android?.smallIcon,
                icon:  '@mipmap/ic_launcher',
                // other properties...
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async{
      Logger().d('notification .....onMessageOpenedApp');
      Logger().d(message.toMap());

      // ChatCtrl.find.joinRecentChat();
      // ChatCtrl.find.fireRecentChatEvent();
      _handleNotificationClick(message);

    });
    FirebaseMessaging.onBackgroundMessage((message) async{
      await Firebase.initializeApp();
      Logger().d('notification .....onBackgroundMessage');
      Logger().d(message.toMap());
      ChatCtrl.find.fireRecentChatEvent();




      // ChatCtrl.find.joinRecentChat();

      // {
      //   "senderId": null,
      //   "category": null,
      //   "collapseKey": "com.app.kioski",
      //   "contentAvailable": false,
      //   "data": {
      //     "payload": "{\"name\":\"buyer\",\"email\":\"bhd@gmail.com\",\"image\":\"Abcd.jpg\",\"mobileNumber\":\"+911212121212\"}",
      //     "body": "Peter parker!!",
      //     "type": "Chat messages",
      //     "title": "buyer Sends you a message"
      //   },
      //   "from": "220349326802",
      //   "messageId": "0:1720419631315518%e989679ae989679a",
      //   "messageType": null,
      //   "mutableContent": false,
      //   "notification": {
      //     "title": "buyer Sends you a message",
      //     "titleLocArgs": [],
      //     "titleLocKey": null,
      //     "body": "Peter parker!!",
      //     "bodyLocArgs": [],
      //     "bodyLocKey": null,
      //     "android": {
      //       "channelId": null,
      //       "clickAction": null,
      //       "color": null,
      //       "count": null,
      //       "imageUrl": null,
      //       "link": null,
      //       "priority": 0,
      //       "smallIcon": null,
      //       "sound": null,
      //       "ticker": null,
      //       "tag": null,
      //       "visibility": 0
      //     },
      //     "apple": null,
      //     "web": null
      //   },
      //   "sentTime": 1720419631307,
      //   "threadId": null,
      //   "ttl": 2419200
      // }

    });
  }


  static  Future<bool> _requestPermissions() async{
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      sound: true,
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      return true;
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
      return false;
    } else {
      print('User declined or has not accepted permission');
      return false;
    }
  }

  static void _onNotificationClick(NotificationResponse response) {
    onClick();
  }

  static onClick(){

    AppUtils.log('clickk fgregregreg');

    // try{
      if (_payloadData != null) {
        final type = _payloadData!['type'];
        if (type == 'LIVE_STARTED' || type == 'inviteForLive') {
          final isLiveStarted = type == 'LIVE_STARTED';
          final requestAsBroadCaster = type == 'inviteForLive';
          String? hostId;
          String? roomId;
          String? hostName;
          if (isLiveStarted) {
            hostId = _payloadData?['hostId'] ?? '';
            hostName = _payloadData?['hostName'] ?? '';
            roomId = _payloadData?['roomId'];
          }
          if (requestAsBroadCaster) {
            hostId = _payloadData?['sentBy'] ?? '';
            hostName = '';
            roomId = _payloadData?['channelId'];
          }


          //     I/flutter ( 7340): │ 🐛     "hostName": "test ios 2",
          // I/flutter ( 7340): │ 🐛     "hostId": "687a274d642948724b3e7ca2",
          // I/flutter ( 7340): │ 🐛     "type": "LIVE_STARTED",
          // I/flutter ( 7340): │ 🐛     "roomId": "live_687a274d642948724b3e7ca2_1753787352344"

          ClientRoleType? role = requestAsBroadCaster ? ClientRoleType
              .clientRoleBroadcaster : null;
          bool connectionCallBack = false;
          AgoraChatCtrl.find.joinLiveChannel(
              LiveStreamChannelModel(
                channelId: roomId,
                hostId: hostId,
                hostName: hostName,
              ), role,
              connectionCallBack, (value) {});
          // navState.currentContext?.pushNavigator(
          //     BroadCastVideo(
          //       clientRole: isLiveStarted ? ClientRoleType.clientRoleAudience : ClientRoleType.clientRoleBroadcaster,
          //       hostId: hostId,
          //       hostName: hostName,
          //     )

          //
          //         I/flutter (17539): │ 🐛     "sentTo": "687a274d642948724b3e7ca2",
          // I/flutter (17539): │ 🐛     "type": "inviteForLive",
          // I/flutter (17539): │ 🐛     "channelId": "live_683a8cc26a337827c39db2ef_1753267168170",
          // I/flutter (17539): │ 🐛     "sentBy": "683a8cc26a337827c39db2ef"
          //     );
        }

        _payloadData = null;
      }


      // I/flutter ( 2818): │ 🐛 {
      // I/flutter ( 2818): │ 🐛   "hostName": "Chandan Sharma",
      // I/flutter ( 2818): │ 🐛   "hostId": "686ca52d6d4732abc2612876",
      // I/flutter ( 2818): │ 🐛   "type": "LIVE_STARTED",
      // I/flutter ( 2818): │ 🐛   "roomId": "live_686ca52d6d4732abc2612876_1752144726111"
      // I/flutter ( 2818): │ 🐛 }}
  // }catch(e){
  //     AppUtils.logEr(e);
  //   }
  }

  static void _handleNotificationClick(RemoteMessage message) {
    // Logger().i('Handle Click: ${message.data}');
    _payloadData = message.data;
    onClick();

    // AppUtils.log({
    //   'notification': '_handleNotificationClick',
    //   'data':message.toMap()
    // });
    // You can navigate or use controller logic
    // if (message.data['type'] == 'chat') {
    //   final msg = ChatItemDataModel.fromJsonGetSingleChat({...}); // Your parsing
    //   _chatCtrl.getMessageListener(msg);
    // }
  }
}




final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
const DarwinInitializationSettings iOSInit = DarwinInitializationSettings();
final initSettings = InitializationSettings(android: androidSettings, iOS: iOSInit );
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true
);


Widget? getCurrentScreen() {
  return ScreenTracker.instance.currentScreen;
}

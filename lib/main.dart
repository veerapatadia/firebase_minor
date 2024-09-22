import 'dart:developer';
import 'package:chat_app/provider/themeprovider.dart';
import 'package:chat_app/views/ChatPage.dart';
import 'package:chat_app/views/HomePage.dart';
import 'package:chat_app/views/LoginPage.dart';
import 'package:chat_app/views/LoginPage2.dart';
import 'package:chat_app/views/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'helper/local_notification_helper.dart';

@pragma('vn:entry-point')
Future<void> onBGFCM(RemoteMessage remoteMessage) async {
  log("========BACKGROUND NOTIFICATION=========");
  log("Title: ${remoteMessage.notification!.title}");
  log("Body: ${remoteMessage.notification!.body}");

  log("Custom Data: ${remoteMessage.data}");
  log("=================================");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) async {
    log("========FOREGROUND NOTIFICATION=========");
    log("Title: ${remoteMessage.notification!.title}");
    log("Body: ${remoteMessage.notification!.body}");

    log("Custom Data: ${remoteMessage.data}");
    log("=================================");
    await LocalNotificationHelper.localNotificationHelper
        .showSimpleNotification(
            title: remoteMessage.notification!.title!,
            dis: remoteMessage.notification!.body!);
  });

  FirebaseMessaging.onBackgroundMessage(onBGFCM);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: myApp(),
    ),
  );
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          initialRoute: 'splash_screen',
          theme: Provider.of<ThemeProvider>(context).themeData,
          debugShowCheckedModeBanner: false,
          routes: {
            '/': (context) => HomePage(),
            'splash_screen': (context) => SplashScreen(),
            'login_page1': (context) => LoginPage1(),
            'login_page2': (context) => LoginPage2(),
            'chat_page': (context) => ChatPage(),
          },
        );
      },
    );
  }
}

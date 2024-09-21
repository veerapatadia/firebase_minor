import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class FCMNotificationHelper {
  FCMNotificationHelper._();
  static final FCMNotificationHelper fcmNotification =
      FCMNotificationHelper._();

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  //fetch FCM registration token
  Future<String?> fetchFCmToken() async {
    String? token = await firebaseMessaging.getToken();
    log("=============");
    log("FCM Token $token");
    log("=============");
    return token;
  }

  Future<String> getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
      await rootBundle.loadString(
          'assets/chat-app-34732-firebase-adminsdk-riqpu-07c77e07e8.json'),
    );
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient =
        await clientViaServiceAccount(accountCredentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  Future<void> sendFCM(
      {required String msg,
      required String senderEmail,
      required String token}) async {
    // String? token = await FCMNotificationHelper.fcmNotification.fetchFCmToken();
    final String accessToken = await getAccessToken();
    final String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/chat-app-34732/messages:send';
    final Map<String, dynamic> myBody = {
      'message': {
        'token': token,
        'notification': {
          'title': msg,
          'body': senderEmail,
        },
      },
    };
    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(myBody),
    );
    if (response.statusCode == 200) {
      print('-------------------');
      print('Notification sent successfully');
      print('-------------------');
    } else {
      print('-------------------');
      print('Failed to send notification:${response.body}');
      print('-------------------');
    }
  }
}

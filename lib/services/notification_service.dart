import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification(BuildContext context, String userId) async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permission for notifications
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get the FCM token and save it to Firebase Realtime Database
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    // Save the FCM token to Firebase Database
    await saveFcmTokenToDatabase(token, userId);

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    print('Received a message: ${message.data}');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'com.example.untitled5.channel', // Unique channel ID, adjust as needed
      'Daily Quotes',
      channelDescription: 'Daily motivational quotes for inspiration.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(), // Optional payload
    );
  }

  Future<void> saveFcmTokenToDatabase(String? token, String userId) async {
    if (token == null) return;

    try {
      DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId');
      await userRef.update({'fcmToken': token});
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  Future<void> setupNotificationForUser(String userId) async {
    // Logic for scheduling notifications or setting user preferences
    // (to be implemented in Firebase Cloud Functions or backend logic)
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class Notify {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initializeNotifications() async {
    // Initialize Firebase Messaging
    await _firebaseMessaging.requestPermission();
  }

  static Future<void> sendNotification(
      BuildContext context, String friendName) async {
    try {
      final friendSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: friendName)
          .get();

      if (friendSnapshot.docs.isNotEmpty) {
        final friendDoc = friendSnapshot.docs.first;
        final friendUsername = friendDoc['username'];
        final fcmToken = friendDoc['fcmToken'];

        final serverKey =
            'AAAA99JnmJg:APA91bGDu-pBEK8NsXEv91QzpnWjz9yajkEv9S_QTw578jmFSfFmCenNzh2Z0ggDtEFyLWcNfa1G4A9WKA8d34oOX7ctmlWF7pSerOFj40gBM6VgngcXwzyKj5jaiXIwFZYQn7NtmQ7Z';

        final headers = <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        };

        final notification = {
          'title': 'Notification',
          'body': 'You have a debt to pay.',
        };

        final message = {
          'to': fcmToken,
          'notification': notification,
        };

        final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: headers,
          body: jsonEncode(message),
        );

        print('FCM Response Code: ${response.statusCode}');
        print('FCM Response Body: ${response.body}');
        print('FCM Response Headers: ${response.headers}');

        if (response.statusCode == 200) {
          print('Notification sent successfully to $friendUsername');
        } else {
          print(
              'Failed to send notification to $friendUsername. Error: ${response.statusCode}');
        }
      } else {
        throw Exception('Friend not found.');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

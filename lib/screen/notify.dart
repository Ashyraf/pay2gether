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
            'AAAA99JnmJg:APA91bEgxWOYnok2CpggYEdP_z5t9Phlp6dDqZnoDdT3RfM8tN3ulTq60HxbEsPjnfLTDlHOApyyf-nkIhm7rD_6j7zMu27AUE6PAhChW3JRHZcCCYQZHdwmQqWFpGhcT9we9N4QCWnb';

        final headers = <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        };

        final notification = {
          'title': 'Notification',
          'body': 'You have a debt to pay.',
        };

        final message = {
          'token': fcmToken,
          'notification': notification,
        };

        final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: headers,
          body: jsonEncode(message),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully to $friendUsername');
        } else {
          print('Failed to send notification');
        }
      } else {
        throw Exception('Friend not found.');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

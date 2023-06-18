import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
      final currentUser = FirebaseAuth.instance.currentUser;

      final friendSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: friendName)
          .get();

      if (friendSnapshot.docs.isNotEmpty) {
        final friendDoc = friendSnapshot.docs.first;
        final friendEmail = friendDoc['email'];

        // Retrieve the user document based on the friendEmail
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: friendEmail)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userDoc = userSnapshot.docs.first;
          final userName = userDoc['username'];
          final fcmToken = userDoc['fcmToken'];

          // Replace this code with your server-side logic to send the notification
          // Typically, you would make an API call to your backend server or use cloud functions to send the notification

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Notification'),
              content: Text('You have a debt to pay.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        } else {
          throw Exception('User not found.');
        }
      } else {
        throw Exception('Friend not found.');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

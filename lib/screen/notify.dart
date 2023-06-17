import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notify {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications(BuildContext context) async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
          // Extract the necessary information from the user document
          final userName = userDoc['username'];

          // Send the notification to the user using your preferred method
          // Replace the comment with your implementation to send the notification to the user identified by friendEmail
          // You can use the userName and friendName variables to personalize the notification

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

// ignore_for_file: unused_import

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class ReportDialog extends StatefulWidget {
  final String roomName;
  final String friendName;

  const ReportDialog({
    required this.roomName,
    required this.friendName,
  });

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? selectedReason;
  String? optionalReason;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedReason,
            hint: Text('Reason'),
            onChanged: (value) {
              setState(() {
                selectedReason = value;
              });
            },
            items: [
              DropdownMenuItem(
                value: 'Reason 1',
                child: Text('Added in the wrong Room.'),
              ),
              DropdownMenuItem(
                value: 'Reason 2',
                child: Text('Wrong amount of debt.'),
              ),
              DropdownMenuItem(
                value: 'Reason 3',
                child: Text('others.'),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Optional',
            ),
            onChanged: (value) {
              optionalReason = value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
          ),
          child: Text('Send Report'),
          onPressed: () {
            _sendReport();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _sendReport() {
    final report = {
      'reportertName': widget.friendName,
      'roomName': widget.roomName,
      'reason': selectedReason,
      'optionalReason': optionalReason,
    };

    FirebaseFirestore.instance.collection('debtRoom').doc(widget.roomName).set({
      'reports': [report]
    }, SetOptions(merge: true)).then((value) {
      // Report sent successfully
      print('Report sent successfully!');
      _sendNotificationToRoomMaster(widget.roomName);
    }).catchError((error) {
      // Error occurred while sending the report
      print('Error sending report: $error');
    });
  }

  void _sendNotificationToRoomMaster(String roomName) {
    FirebaseFirestore.instance
        .collection('debtRoom')
        .doc(roomName)
        .get()
        .then((roomSnapshot) {
      if (roomSnapshot.exists) {
        final roomMasterEmail = roomSnapshot.data()?['roomMaster'];
        FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: roomMasterEmail)
            .get()
            .then((userSnapshot) {
          if (userSnapshot.docs.isNotEmpty) {
            final roomMasterDoc = userSnapshot.docs.first;
            final roomMasterToken = roomMasterDoc['fcmToken'];
            final roomMasterUsername = roomMasterDoc['username'];

            final serverKey =
                'AAAA99JnmJg:APA91bGDu-pBEK8NsXEv91QzpnWjz9yajkEv9S_QTw578jmFSfFmCenNzh2Z0ggDtEFyLWcNfa1G4A9WKA8d34oOX7ctmlWF7pSerOFj40gBM6VgngcXwzyKj5jaiXIwFZYQn7NtmQ7Z';

            final headers = <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'key=$serverKey',
            };

            final notification = {
              'title': 'REPORT',
              'body': 'There is a report from ${widget.friendName}.',
            };

            final message = {
              'to': roomMasterToken,
              'notification': notification,
            };

            http
                .post(
              Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: headers,
              body: jsonEncode(message),
            )
                .then((response) {
              print('FCM Response Code: ${response.statusCode}');
              print('FCM Response Body: ${response.body}');
              print('FCM Response Headers: ${response.headers}');

              if (response.statusCode == 200) {
                print('Notification sent successfully to $roomMasterUsername');
              } else {
                print(
                    'Failed to send notification to $roomMasterUsername. Error: ${response.statusCode}');
              }
            }).catchError((error) {
              print('Error sending notification: $error');
            });
          } else {
            print('Room master not found.');
          }
        });
      } else {
        print('Debt room not found.');
      }
    });
  }
}

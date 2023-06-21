import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pay2gether/screen/notify.dart';
import 'managereport.dart'; // Import the managereport.dart file

class MasterRoomCardExtend extends StatefulWidget {
  final Map<String, dynamic> roomData;
  final String roomName;

  const MasterRoomCardExtend({required this.roomData, required this.roomName});

  @override
  _MasterRoomCardExtendState createState() => _MasterRoomCardExtendState();
}

class _MasterRoomCardExtendState extends State<MasterRoomCardExtend> {
  bool isPaymentOpen = false;

  @override
  Widget build(BuildContext context) {
    final roomName = widget.roomData['roomName'] ?? '';
    final selectedFriends = widget.roomData['selectedFriends'] as List<dynamic>;
    final paymentData = widget.roomData['Payment'];
    final meetupData = widget.roomData['meetUp'];

    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
      ),
      body: ListView.builder(
        itemCount: selectedFriends.length + 1,
        itemBuilder: (context, index) {
          if (index == selectedFriends.length) {
            return Center(
              child: ElevatedButton(
                child: Text('Open Payment'),
                onPressed: () {
                  setState(() {
                    isPaymentOpen = true;
                  });
                },
              ),
            );
          }

          final friend = selectedFriends[index];
          final friendName = friend['friendName'];
          final debtAmount = friend['debtAmount'];
          final status = friend['status'];
          final hasReport = hasFriendReport(widget.roomData, friendName);

          Widget paymentDetailsWidget;

          if (isPaymentOpen) {
            if (paymentData != null &&
                paymentData['friendName'] == friendName) {
              final receiptUrl = paymentData['receiptUrl'];

              paymentDetailsWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Debt Amount: \$${debtAmount.toStringAsFixed(2)}'),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Status: '),
                      _buildCircleAvatar(status),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Payment Option: Online Transfer'),
                  Text('Receipt URL: $receiptUrl'),
                ],
              );
            } else if (meetupData != null &&
                meetupData['friendName'] == friendName) {
              final location = meetupData['location'];
              final date = meetupData['date'];
              final time = meetupData['time'];

              paymentDetailsWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Debt Amount: \$${debtAmount.toStringAsFixed(2)}'),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Status: '),
                      _buildCircleAvatar(status),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Payment Option: Meet Up'),
                  Text('Location: $location'),
                  Text(
                      'Date: ${DateTime.fromMillisecondsSinceEpoch(date).toString()}'),
                  Text('Time: $time'),
                ],
              );
            } else {
              paymentDetailsWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Debt Amount: \$${debtAmount.toStringAsFixed(2)}'),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Status: '),
                      _buildCircleAvatar(status),
                    ],
                  ),
                ],
              );
            }
          } else {
            paymentDetailsWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Debt Amount: \$${debtAmount.toStringAsFixed(2)}'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Status: '),
                    _buildCircleAvatar(status),
                  ],
                ),
              ],
            );
          }

          return Card(
            child: ListTile(
              title: Text('Friend Name: $friendName'),
              subtitle: paymentDetailsWidget,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!hasReport) ...[
                    ElevatedButton(
                      child: Text('Verified'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ManageReportDialog(
                              friendName: friendName,
                              roomData: widget.roomData,
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      child: Text('Notify'),
                      onPressed: () {
                        Notify.sendNotification(context, friendName);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                      ),
                    ),
                  ] else ...[
                    ElevatedButton(
                      child: Text('View Report'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ManageReportDialog(
                              friendName: friendName,
                              roomData: widget.roomData,
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircleAvatar(String status) {
    Color? circleColor;
    switch (status) {
      case 'pending':
        circleColor = Colors.red;
        break;
      case 'verification':
        circleColor = Colors.yellow;
        break;
      case 'verified':
        circleColor = Colors.green;
        break;
      default:
        circleColor = Colors.grey;
        break;
    }

    return CircleAvatar(
      radius: 10,
      backgroundColor: circleColor,
    );
  }

  bool hasFriendReport(Map<String, dynamic> roomData, String friendName) {
    final reports = roomData['reports'] as List<dynamic>?;

    if (reports != null) {
      for (final report in reports) {
        final reporterName = report['reporterName'];

        if (reporterName == friendName) {
          return true;
        }
      }
    }

    return false;
  }
}

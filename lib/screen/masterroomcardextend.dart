import 'package:flutter/material.dart';
import 'package:pay2gether/screen/notify.dart';
import 'managereport.dart'; // Import the managereport.dart file

class MasterRoomCardExtend extends StatelessWidget {
  final Map<String, dynamic> roomData;
  final String roomName;

  const MasterRoomCardExtend({required this.roomData, required this.roomName});

  @override
  Widget build(BuildContext context) {
    final roomName = roomData['roomName'] ?? '';
    final selectedFriends = roomData['selectedFriends'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
      ),
      body: ListView.builder(
        itemCount: selectedFriends.length,
        itemBuilder: (context, index) {
          final friend = selectedFriends[index];
          final friendName = friend['friendName'];
          final debtAmount = friend['debtAmount'];
          final status = friend['status'];
          final hasReport = hasFriendReport(roomData, friendName);

          return Card(
            child: ListTile(
              title: Text('Friend Name: $friendName'),
              subtitle: Column(
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
              ),
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
                              roomData: roomData,
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
                              roomData: roomData,
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

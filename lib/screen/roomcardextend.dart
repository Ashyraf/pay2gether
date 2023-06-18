import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomCardExtend extends StatefulWidget {
  final Map<String, dynamic> roomData;
  final String roomName;
  final List<dynamic> bankAccounts;
  final String roomMaster;

  const RoomCardExtend({
    required this.roomData,
    required this.roomName,
    required this.bankAccounts,
    required this.roomMaster,
  });

  @override
  _RoomCardExtendState createState() => _RoomCardExtendState();
}

class _RoomCardExtendState extends State<RoomCardExtend> {
  late String currentUser;
  String roomMasterUsername = '';

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    fetchRoomMasterUsername();
  }

  void fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user.displayName ?? '';
      });
    }
  }

  void fetchRoomMasterUsername() async {
    final roomMasterEmail = widget.roomMaster;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: roomMasterEmail)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final roomMasterData = snapshot.docs.first.data();
      setState(() {
        roomMasterUsername = roomMasterData['username'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomData = widget.roomData;
    final roomName = widget.roomName;
    final bankAccounts = widget.bankAccounts;
    final selectedFriends = roomData['selectedFriends'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Room Master: $roomMasterUsername',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Bank Accounts:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: bankAccounts.length,
            itemBuilder: (context, index) {
              final account = bankAccounts[index];
              final bankName = account['bankName'];
              final accountNumber = account['accountNumber'];

              return ListTile(
                title: Text('Account Name: $bankName'),
                subtitle: Text('Account Number: $accountNumber'),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selected Friends:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedFriends.length,
              itemBuilder: (context, index) {
                final friend = selectedFriends[index];
                final friendName = friend['friendName'];
                final debtAmount = friend['debtAmount'];
                final status = friend['status'];

                final isCurrentUser = friendName ==
                    FirebaseAuth.instance.currentUser?.displayName;

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
                    trailing: isCurrentUser
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                child: Text('Payment'),
                                onPressed: () {
                                  // Handle payment button press
                                },
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                ),
                                child: Text('Report'),
                                onPressed: () {
                                  _showReportDialog(context, friendName);
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
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

  void _showReportDialog(BuildContext context, String friendName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReportDialog(
          roomName: widget.roomName,
          friendName: friendName,
        );
      },
    );
  }
}

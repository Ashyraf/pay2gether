import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pay2gether/screen/Payment/meetup.dart';
import 'package:pay2gether/screen/Payment/transfer.dart';
import 'report.dart';

class RoomCardExtend extends StatefulWidget {
  final Map<String, dynamic> roomData;
  final String roomName;
  // final List<dynamic> bankAccounts;
  final String roomMaster;

  const RoomCardExtend({
    required this.roomData,
    required this.roomName,
    // required this.bankAccounts,
    required this.roomMaster,
  });

  @override
  _RoomCardExtendState createState() => _RoomCardExtendState();
}

class _RoomCardExtendState extends State<RoomCardExtend> {
  late String currentUser;
  String roomMasterEmail = '';
  String roomMaster = '';
  bool isVerificationPending = false;
  bool isPaymentDone = false;
  late StreamSubscription<DocumentSnapshot> statusSubscription;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();

    // Check if a meet-up or payment has been done
    if (widget.roomData['Payment'] != null) {
      setState(() {
        isVerificationPending = true;
      });
    }

    // Subscribe to real-time updates for the friend's status
    final roomDocument =
        FirebaseFirestore.instance.collection('debtRoom').doc(widget.roomName);
    statusSubscription = roomDocument.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final selectedFriends = snapshot.data()?['selectedFriends'];
        final currentUserData = selectedFriends.firstWhere(
          (friend) => friend['friendName'] == currentUser,
          orElse: () => null,
        );
        if (currentUserData != null) {
          final status = currentUserData['status'];
          if (status == 'verified') {
            setState(() {
              // Update the specific friend's status
              currentUserData['isVerificationPending'] = false;
            });
            // Update the document with the modified selectedFriends list
            roomDocument.update({'selectedFriends': selectedFriends});
          } else if (status == 'pending') {
            // Check if there is a payment under the friendName
            final paymentExists = widget.roomData['Payment'] != null &&
                widget.roomData['Payment'][currentUser] != null;
            if (paymentExists) {
              setState(() {
                // Update the specific friend's status
                currentUserData['status'] = 'verification';
              });
              // Update the document with the modified selectedFriends list
              roomDocument.update({'selectedFriends': selectedFriends});
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    statusSubscription
        .cancel(); // Cancel the subscription to avoid memory leaks
    super.dispose();
  }

  void fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user.displayName ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomData = widget.roomData;
    final roomName = widget.roomName;
    final roomMaster = widget.roomMaster;
    // final bankAccounts = widget.bankAccounts;
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
              'Room Master: $roomMaster',
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
          // ListView.builder(
          //   shrinkWrap: true,
          //   physics: NeverScrollableScrollPhysics(),
          //   itemCount: bankAccounts.length,
          //   itemBuilder: (context, index) {
          //     final account = bankAccounts[index];
          //     final bankName = account['bankName'];
          //     final accountNumber = account['accountNumber'];

          //     return ListTile(
          //       title: Text('Account Name: $bankName'),
          //       subtitle: Text('Account Number: $accountNumber'),
          //     );
          //   },
          // ),
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
                final debtDetails = friend['debtDetails'];

                final isCurrentUser = friendName ==
                    FirebaseAuth.instance.currentUser?.displayName;

                return Card(
                  child: ListTile(
                    title: Text('$friendName'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Debt Amount: \$${debtAmount.toStringAsFixed(2)}'),
                        if (debtDetails !=
                            null) // Check if debtDetails is not null
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              for (var itemDetails
                                  in debtDetails) // Loop through the array
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Item: ${itemDetails['item']}'),
                                    Text(
                                        'Cost: \$${itemDetails['itemCost'].toStringAsFixed(2)}'),
                                    SizedBox(height: 8),
                                  ],
                                ),
                            ],
                          ),
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
                        ? isVerificationPending
                            ? Text('Waiting Verification...')
                            : isPaymentDone
                                ? Text('Done Payment!')
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        child: Text('Payment'),
                                        onPressed: () {
                                          _showPaymentDialog(
                                              context,
                                              roomName,
                                              friendName,
                                              debtAmount,
                                              roomMaster);
                                        },
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.red,
                                        ),
                                        child: Text('Report'),
                                        onPressed: () {
                                          _showReportDialog(
                                              context, friendName);
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

  void _showPaymentDialog(BuildContext context, String roomName,
      String friendName, double debtAmount, String roomMaster) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an action'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Text('Set Meet-Up'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeetupPage(
                        roomName: roomName,
                        friendName: friendName,
                      ),
                    ),
                  );
                },
              ),
              ElevatedButton(
                child: Text('Transfer'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransferPage(
                        roomName: roomName,
                        friendName: friendName,
                        debtAmount: debtAmount,
                        roomMaster: roomMaster,
                        // bankAccounts: widget.bankAccounts,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pay2gether/screen/RoomUser/roomcardextend.dart';

class RoomCard extends StatefulWidget {
  @override
  _RoomCardState createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  late String currentUserUsername;

  @override
  void initState() {
    super.initState();
    // Get the current user's display name
    final user = FirebaseAuth.instance.currentUser;
    currentUserUsername = user != null ? user.displayName ?? '' : '';
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('debtRoom').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        // Filter the snapshot data based on the current user's username
        final filteredData = snapshot.data!.docs.where((doc) {
          final selectedFriends = doc['selectedFriends'] as List<dynamic>;
          final friendNames =
              selectedFriends.map((friend) => friend['friendName']).toList();
          return friendNames.contains(currentUserUsername);
        }).toList();

        if (filteredData.isEmpty) {
          return Center(
            child: Text('No rooms found for the current user.'),
          );
        }

        return ListView.builder(
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final roomData = filteredData[index].data() as Map<String, dynamic>;
            final roomName = roomData['roomName'] ?? '';
            final roomMaster =
                roomData['roomMaster'] ?? ''; // Retrieve roomMaster

            // // Retrieve bankAccounts from the debtRoom collection
            // final bankAccounts = roomData['bankAccounts'] ?? [];

            // Calculate total debt from the selectedFriends
            double totalDebt = 0;
            final selectedFriends =
                roomData['selectedFriends'] as List<dynamic>;
            for (final friend in selectedFriends) {
              final friendName = friend['friendName'] ?? '';
              final debtAmount = friend['debtAmount'] ?? 0;
              final status = friend['status'] ?? '';

              totalDebt += debtAmount.toDouble();

              print('Friend Name: $friendName');
              print('Debt Amount: $debtAmount');
              print('Status: $status');
            }

            return Card(
              child: ListTile(
                title: Text(roomName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final friend in selectedFriends)
                      Row(
                        children: [
                          Text('${friend['friendName']}'),
                          SizedBox(width: 8),
                          Text('\$${friend['debtAmount'].toStringAsFixed(2)}'),
                          SizedBox(width: 8),
                          _buildCircleAvatar(friend['status']),
                        ],
                      ),
                    SizedBox(height: 8),
                    Text(
                      'Total Debt: \$${totalDebt.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomCardExtend(
                          roomData: roomData,
                          roomName: roomName,
                          // bankAccounts: bankAccounts,
                          roomMaster:
                              roomMaster, // Pass roomMaster to RoomCardExtend
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

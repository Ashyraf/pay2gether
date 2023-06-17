import 'package:flutter/material.dart';

class RoomCardExtend extends StatelessWidget {
  final Map<String, dynamic> roomData;
  final String roomName;

  const RoomCardExtend({required this.roomData, required this.roomName});
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
              trailing: ElevatedButton(
                child: Text('Payment'),
                onPressed: () {
                  // Handle payment button press
                },
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
}

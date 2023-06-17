import 'package:flutter/material.dart';

class RoomCardExtend extends StatelessWidget {
  final Map<String, dynamic> roomData;
  final String roomName;
  final List<dynamic> bankAccounts;

  const RoomCardExtend({
    required this.roomData,
    required this.roomName,
    required this.bankAccounts,
  });

  @override
  Widget build(BuildContext context) {
    final roomName = roomData['roomName'] ?? '';
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
                            // Handle report button press
                          },
                        ),
                      ],
                    ),
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
}

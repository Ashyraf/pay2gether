import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {
  final String roomName;
  final String roomDescription;

  RoomCard({required this.roomName, required this.roomDescription});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              roomName,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              roomDescription,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

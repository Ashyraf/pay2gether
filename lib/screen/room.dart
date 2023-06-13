import 'package:flutter/material.dart';

class RoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Room Page"),
      ),
      body: Center(
        child: Text(
          "Welcome to the Room Page!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

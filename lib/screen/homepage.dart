import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../reusable_widget/reuse.dart';
import 'friend.dart';
import 'login.dart';
import 'profile_page.dart';
import 'room.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PreferredSizeWidget appbar(BuildContext context) {
    return AppBar(
      title: logoWidget("assets/images/applogosmall.png"),
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.grey,
      leading: IconButton(
        icon: Icon(Icons.person), // Change the icon to a profile icon
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        },
        color: Colors.black,
      ),
      actions: [
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.power), // Change the icon to a power icon
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  print("SIGN OUT");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogiIn()),
                  );
                });
              },
              color: Colors.black,
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context), // Add the appbar widget here
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Friends"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Friend()),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text("Create a Room"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoomPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

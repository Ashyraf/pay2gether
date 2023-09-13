import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pay2gether/reusable_widget/reuse.dart';
import 'package:pay2gether/screen/Friend/friend.dart';
import 'package:pay2gether/screen/LoginRegister/login.dart';
import 'package:pay2gether/screen/MasterRoom/masterroomcard.dart';
import 'package:pay2gether/screen/RoomUser/roomcard.dart';

import 'profile_page.dart';
import 'room.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
        icon: Icon(Icons.person),
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
              icon: const Icon(Icons.power),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  print("SIGN OUT");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
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
      appBar: appbar(context),
      body: Column(
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
          Expanded(
            child: MasterRoomCard(),
          ),
          SizedBox(height: 16),
          Expanded(
            child: RoomCard(),
          ),
          SizedBox(height: 16),
          RoomPage.createRoomButton(context),
        ],
      ),
    );
  }
}

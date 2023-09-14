import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pay2gether/screen/HomeMain/CreateRoom.dart';
import '../Design/Hex_Color.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 70,
    height: 70,
  );
}

Decoration decorationWithBackground() {
  return BoxDecoration(
    image: DecorationImage(
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
          HexColor("#fff").withOpacity(0.6), BlendMode.dstATop),
      image: AssetImage("assets/images/backgroundpay.jpg"),
    ),
  );
}

PreferredSizeWidget reusableAppBar(
    GlobalKey<ScaffoldState> scaffoldKey, BuildContext context) {
  return AppBar(
    title: logoWidget("assets/images/Paylogo.png"),
    elevation: 10,
    shadowColor: Colors.grey,
    centerTitle: true,
    backgroundColor: Colors.grey,
    leading: IconButton(
      icon: Icon(Icons.menu),
      onPressed: () {
        scaffoldKey.currentState?.openDrawer();
      },
      color: Colors.black,
    ),
    actions: [
      Builder(builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(
            Icons.add_home_outlined,
          ),
          onPressed: () {
            final currentUser = FirebaseAuth.instance.currentUser;
            final currentUserEmail = currentUser?.email;

            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserEmail)
                .get()
                .then((userSnapshot) {
              final bankAccounts = userSnapshot.data()?['bankAccounts'];
              if (bankAccounts == null || bankAccounts.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('Please add your bank account first!'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CreateRoom(); // Show the dialog from DetailPlan.dart
                  },
                );
              }
            });
          },
        );
      })
    ],
  );
}

Widget reusableToggleButtons({
  required List<bool> isSelected,
  required Function(int) onPressed,
  required List<String> items,
}) {
  return ToggleButtons(
    isSelected: isSelected,
    onPressed: onPressed,
    renderBorder: true,
    color: Colors.black,
    selectedColor: Colors.black,
    fillColor: Color.fromARGB(255, 233, 233, 233),
    borderRadius: BorderRadius.circular(30),
    borderColor: Colors.black,
    children: items
        .map(
          (item) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(item),
          ),
        )
        .toList(),
  );
}

PreferredSizeWidget reusableAppBarFriend(
    GlobalKey<ScaffoldState> scaffoldKey, BuildContext context) {
  return AppBar(
    title: logoWidget("assets/images/Paylogo.png"),
    elevation: 10,
    shadowColor: Colors.grey,
    centerTitle: true,
    backgroundColor: Colors.grey,
    leading: IconButton(
      icon: Icon(Icons.menu),
      onPressed: () {
        scaffoldKey.currentState?.openDrawer();
      },
      color: Colors.black,
    ),
    actions: [
      Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            color: Colors.black,
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        },
      ),
    ],
  );
}

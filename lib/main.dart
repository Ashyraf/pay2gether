import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pay2gether/Design/Drawer/drawer_state.dart';
import 'package:pay2gether/auth.dart';
import 'package:pay2gether/screen/Friend/friend.dart';
import 'package:pay2gether/screen/HomeMain/homepage.dart';
import 'package:pay2gether/screen/MasterRoom/notify.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Notify.initializeNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (context) => DrawerState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => HomePage(), // Example routes
        '/friend': (context) => FriendScreen(),

        // Define more routes as needed
      },
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const Auth(),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pay2gether/auth.dart';
import 'package:pay2gether/screen/notify.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Notify.initializeNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const Auth(),
    );
  }
}

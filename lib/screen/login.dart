import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pay2gether/Utility/color.dart';
import 'package:pay2gether/screen/homepage.dart';

import '../reusable_widget/reuse.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _usernameTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  bool _isLoading = false;

  Future<void> saveFCMToken(String email, String fcmToken) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(email).get();

    Map<String, dynamic>? userData = snapshot.data();
    String? existingFCMToken = userData?['fcmToken'];

    if (existingFCMToken != null && existingFCMToken != fcmToken) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .update({'fcmToken': fcmToken});
    } else if (existingFCMToken == null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .set({'fcmToken': fcmToken});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("50535D"),
              hexStringToColor("84868D"),
              hexStringToColor("BCC4BD"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/applogo.png"),
                SizedBox(height: 30),
                logRegTextField(
                  "Enter UserName or Email",
                  Icons.person_outline,
                  false,
                  _usernameTextController,
                ),
                SizedBox(height: 20),
                logRegTextField(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator() // Show loading indicator if _isLoading is true
                    : logInButton(context, true, () async {
                        String usernameOrEmail =
                            _usernameTextController.text.trim();
                        String password = _passwordTextController.text.trim();
                        String email;
                        if (usernameOrEmail.contains('@')) {
                          // If the input contains '@', consider it as an email
                          email = usernameOrEmail;
                        } else {
                          // Otherwise, create a dummy email using the username
                          email = "$usernameOrEmail@gmail.com";
                        }

                        setState(() {
                          _isLoading = true; // Start loading
                        });

                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          setState(() {
                            _isLoading = false; // Stop loading
                          });

                          if (userCredential.user != null) {
                            // Retrieve FCM token
                            String? fcmToken =
                                await FirebaseMessaging.instance.getToken();

                            if (fcmToken != null) {
                              // Save FCM token to Firestore
                              await saveFCMToken(email, fcmToken);
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          }
                        } catch (error) {
                          setState(() {
                            _isLoading = false; // Stop loading
                          });

                          print("ERROR: $error");
                        }
                      }),
                registerOption(),
                SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row registerOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Are You New Here??", style: TextStyle(color: Colors.white)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Register()),
            );
          },
          child: const Text(
            "REGISTER HERE",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

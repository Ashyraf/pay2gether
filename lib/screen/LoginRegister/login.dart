// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pay2gether/CustomLoader.dart';
import 'package:pay2gether/Utility/color.dart';
import 'package:pay2gether/reusable_widget/reuse.dart';
import 'package:pay2gether/screen/HomeMain/homepage.dart';
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

  void showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                  "Enter Email",
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
                    ? CircularProgressIndicator()
                    : logInButton(context, true, () async {
                        String usernameOrEmail =
                            _usernameTextController.text.trim();
                        String password = _passwordTextController.text.trim();
                        String email;
                        if (usernameOrEmail.contains('@')) {
                          email = usernameOrEmail;
                        } else {
                          email = "$usernameOrEmail@gmail.com";
                        }

                        setState(() {
                          _isLoading = true;
                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // Prevent user from dismissing the dialog
                            builder: (BuildContext context) {
                              return LoadingScreen();
                            },
                          );
                        });

                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          setState(() {
                            _isLoading = false;
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        } catch (error) {
                          setState(() {
                            _isLoading = false;
                          });

                          showErrorDialog("Wrong Email Or Password !!");
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

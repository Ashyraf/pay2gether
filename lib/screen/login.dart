import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pay2gether/Utility/color.dart';
import 'package:pay2gether/screen/homepage.dart';

import '../reusable_widget/reuse.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _usernameTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Welcome To Pay-2-Gether",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
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
                    : logInButton(context, true, () {
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

                        FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        )
                            .then((value) {
                          setState(() {
                            _isLoading = false; // Stop loading
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        }).catchError((error) {
                          setState(() {
                            _isLoading = false; // Stop loading
                          });

                          print("ERROR: ${error.toString()}");
                        });
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
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

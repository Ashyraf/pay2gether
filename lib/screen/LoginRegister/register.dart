import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pay2gether/Utility/color.dart';
import 'package:pay2gether/reusable_widget/reuse.dart';
import 'package:pay2gether/screen/LoginRegister/login.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();
  File? _previewImage;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (passwordConfirmed()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          String username = _usernameController.text.trim();
          String email = _emailController.text.trim();
          String profileImageUrl = '';

          // Set display name for the user
          await userCredential.user!.updateProfile(displayName: username);

          // Upload profile image if available
          if (_profileImage != null) {
            profileImageUrl = await uploadProfileImage();
          }

          // Retrieve FCM token
          String? fcmToken = await FirebaseMessaging.instance.getToken();

          // Add user details to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(email) // Use email as document ID
              .set({
            'username': username,
            'email': email,
            'profileImageUrl': profileImageUrl,
            'fcmToken': fcmToken,
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
  }

  Future<void> pickProfileImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
        _previewImage = _profileImage;
      });
    }
  }

  Future<String> uploadProfileImage() async {
    String imageUrl = '';

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('profile_images/$fileName')
          .putFile(_profileImage!);
      TaskSnapshot storageSnapshot = await uploadTask;
      imageUrl = await storageSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
    }

    return imageUrl;
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
          child: Column(
            children: [
              SizedBox(height: 80),
              CircleAvatar(
                radius: 64,
                backgroundImage:
                    _previewImage != null ? FileImage(_previewImage!) : null,
                child: _previewImage == null
                    ? Icon(Icons.person, size: 64, color: Colors.grey)
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickProfileImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: logRegTextField(
                  "Enter UserName",
                  Icons.person_outline,
                  false,
                  _usernameController,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: logRegTextField(
                  "Enter Email",
                  Icons.email_outlined,
                  false,
                  _emailController,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: logRegTextField(
                  "Password",
                  Icons.lock_outline,
                  true,
                  _passwordController,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: logRegTextField(
                  "Re-Enter Password",
                  Icons.lock_outline,
                  true,
                  _confirmPasswordController,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: const Text('Register'),
              ),
              SizedBox(height: 30),
              LogInOption(),
              SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Row LogInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Akready Have An Account??",
            style: TextStyle(color: Colors.white)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
          child: const Text(
            "LOG IN NOW!",
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

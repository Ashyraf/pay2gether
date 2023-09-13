import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: const Register(),
    );
  }
}

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

  Future<String> uploadProfileImage() async {
    String imageUrl = '';

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('profile_images/$fileName')
          .putFile(_profileImage!);
      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
      imageUrl = await storageSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
    }

    return imageUrl;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (_profileImage != null)
              CircleAvatar(
                radius: 60,
                backgroundImage: FileImage(_profileImage!),
              ),
            ElevatedButton(
              onPressed: pickProfileImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

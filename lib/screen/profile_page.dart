import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    // Load user data from Firestore
    loadUserData();
  }

  Future<void> loadUserData() async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection('users').doc('username').get();

    if (userDoc.exists) {
      setState(() {
        _usernameController.text = userDoc.data()?['username'] as String? ?? '';
        _emailController.text = userDoc.data()?['email'] as String? ?? '';
        _profileImageUrl = userDoc.data()?['profileImageUrl'] as String? ?? '';
      });
    }
  }

  Future<void> updateUser() async {
    String username = _usernameController.text;
    String email = _emailController.text;

    await _firestore.collection('users').doc('users').update({
      'username': username,
      'email': email,
    });

    // Reload user data after updating
    loadUserData();
  }

  Future<void> uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String fileName = 'profile_image.jpg';
      Reference storageRef = _storage.ref().child('profile_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(pickedFile.path));

      await uploadTask.whenComplete(() async {
        String profileImageUrl = await storageRef.getDownloadURL();
        await _firestore.collection('users').doc('users').update({
          'profileImageUrl': profileImageUrl,
        });
        // Reload user data after updating profile image
        loadUserData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            CircleAvatar(
              radius: 64,
              backgroundImage: _profileImageUrl.isNotEmpty
                  ? NetworkImage(_profileImageUrl)
                  : null,
              child: _profileImageUrl.isEmpty
                  ? Icon(Icons.person, size: 64, color: Colors.grey)
                  : null,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: updateUser,
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('Upload Profile Photo'),
            ),
          ],
        ),
      ),
    );
  }
}

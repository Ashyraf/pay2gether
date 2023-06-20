import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<Map<String, TextEditingController>> _bankAccounts = [];
  bool _isAddingBankAccount = false;
  List<Map<String, String>> _savedBankAccounts = [];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    // Load user data from Firestore
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserEmail = user.email!;
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(currentUserEmail).get();

      if (userDoc.exists) {
        setState(() {
          _usernameController.text =
              userDoc.data()?['username'] as String? ?? '';
          _emailController.text = currentUserEmail;
          _profileImageUrl =
              userDoc.data()?['profileImageUrl'] as String? ?? '';

          // Handle the dynamic type of bankAccounts field
          var bankAccounts = userDoc.data()?['bankAccounts'];
          if (bankAccounts != null && bankAccounts is List<dynamic>) {
            _savedBankAccounts = List<Map<String, String>>.from(
              bankAccounts.map<Map<String, String>>(
                (dynamic item) => item.cast<String, String>(),
              ),
            );
          } else {
            _savedBankAccounts = [];
          }
        });
      }
    }
  }

  Future<void> updateUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserEmail = user.email!;
      String username = _usernameController.text;
      String email = _emailController.text;

      // Update username and email in Firestore
      await _firestore.collection('users').doc(currentUserEmail).set({
        'username': username,
        'email': email,
      }, SetOptions(merge: true));

      // Update or add bank account information
      await _firestore.collection('users').doc(currentUserEmail).set({
        'bankAccounts': _savedBankAccounts,
      }, SetOptions(merge: true));

      // Reload user data after updating
      await loadUserData();

      // Display a snackbar to indicate successful update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully.'),
        ),
      );
    }
  }

  Future<void> uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String fileName = 'profile_image.jpg';
      Reference storageRef = _storage.ref().child('profile_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(pickedFile.path));

      await uploadTask.whenComplete(() async {
        String profileImageUrl = await storageRef.getDownloadURL();
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String currentUserEmail = user.email!;
          await _firestore.collection('users').doc(currentUserEmail).update({
            'profileImageUrl': profileImageUrl,
          });
          // Reload user data after updating profile image
          await loadUserData();
        }
      });
    }
  }

  void addBankAccount() {
    setState(() {
      _isAddingBankAccount = true;
      _bankAccounts.add({
        'bankName': TextEditingController(),
        'accountNumber': TextEditingController(),
      });
    });
  }

  void saveBankAccounts() {
    // Perform the save operation or any necessary validation
    for (var bankAccount in _bankAccounts) {
      String bankName = bankAccount['bankName']!.text;
      String accountNumber = bankAccount['accountNumber']!.text;
      _savedBankAccounts.add({
        'bankName': bankName,
        'accountNumber': accountNumber,
      });
    }

    setState(() {
      _isAddingBankAccount = false;
      _bankAccounts.clear();
    });
  }

  void cancelBankAccounts() {
    setState(() {
      _isAddingBankAccount = false;
      _bankAccounts.clear();
    });
  }

  Widget buildBankAccountFields(
      Map<String, TextEditingController> bankAccount) {
    return Column(
      children: [
        TextField(
          controller: bankAccount['bankName'],
          decoration: InputDecoration(
            labelText: 'Bank Name',
            hintText: 'Enter bank name',
          ),
        ),
        TextField(
          controller: bankAccount['accountNumber'],
          decoration: InputDecoration(
            labelText: 'Account Number',
            hintText: 'Enter account number',
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  Widget buildSavedBankAccounts() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _savedBankAccounts.length,
      itemBuilder: (context, index) {
        final bankAccount = _savedBankAccounts[index];
        return ListTile(
          title: Text(
              '${bankAccount['bankName']} - ${bankAccount['accountNumber']}'),
          trailing: IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              setState(() {
                _savedBankAccounts.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
              onPressed: uploadImage,
              child: Text('Upload Profile Photo'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: _usernameController.text.isNotEmpty
                    ? _usernameController.text
                    : 'Enter your username',
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: _emailController.text.isNotEmpty
                    ? _emailController.text
                    : 'Enter your email',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Bank Account:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(width: 8.0),
                _isAddingBankAccount
                    ? IconButton(
                        icon: Icon(Icons.save),
                        onPressed: saveBankAccounts,
                      )
                    : IconButton(
                        icon: Icon(Icons.add),
                        onPressed: addBankAccount,
                      ),
              ],
            ),
            SizedBox(height: 8.0),
            if (_isAddingBankAccount)
              ..._bankAccounts
                  .map((bankAccount) => buildBankAccountFields(bankAccount))
                  .toList(),
            if (!_isAddingBankAccount) buildSavedBankAccounts(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: updateUser,
              child: Text('Save Changes'),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

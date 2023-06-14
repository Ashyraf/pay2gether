import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RoomPage extends StatefulWidget {
  const RoomPage({Key? key}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();

  static Widget createRoomButton(BuildContext context) {
    return ElevatedButton(
      child: Text("Create a Room"),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Create a Room'),
              content: SingleChildScrollView(
                // Wrap the content in SingleChildScrollView
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Room name',
                      ),
                    ),
                    SizedBox(height: 16),
                    AddPeopleForm(),
                    SizedBox(height: 16),
                    AddReceiptButton(),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Create'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RoomPageState extends State<RoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Page'),
      ),
      body: Center(
        child: RoomPage.createRoomButton(context),
      ),
    );
  }
}

class AddPeopleForm extends StatefulWidget {
  @override
  _AddPeopleFormState createState() => _AddPeopleFormState();
}

class _AddPeopleFormState extends State<AddPeopleForm> {
  User? currentUser;
  List<Map<String, dynamic>> _friendList = [];
  List<Map<String, dynamic>> selectedFriends = [];
  Map<String, dynamic>? selectedFriendWithDebt;

  final TextEditingController _debtAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getFriendList();
  }

  @override
  void dispose() {
    _debtAmountController.dispose();
    super.dispose();
  }

  void getCurrentUser() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    setState(() {
      currentUser = user;
    });
  }

  Future<void> getFriendList() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserEmail = currentUser?.email;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserEmail)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null && data.containsKey('friendLists')) {
        final friendList = data['friendLists'] as List<dynamic>;

        setState(() {
          _friendList = friendList.cast<Map<String, dynamic>>();
        });
      }
    }
  }

  void addFriendWithDebt() {
    if (selectedFriendWithDebt != null) {
      selectedFriends.add(selectedFriendWithDebt!);
      selectedFriendWithDebt = null;
      _debtAmountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add people:'),
            SizedBox(height: 8),
            if (_friendList.isNotEmpty)
              SizedBox(
                width: 300,
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _friendList.length,
                  itemBuilder: (context, index) {
                    final friend = _friendList[index];
                    final friendName = friend['friendName'];
                    double debtAmount = friend['debtAmount'] ?? 0.0;

                    return Card(
                      child: ListTile(
                        title: Text(friendName ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final TextEditingController
                                        _debtAmountController =
                                        TextEditingController();

                                    return AlertDialog(
                                      title: Text('Add Debt Amount'),
                                      content: TextField(
                                        controller: _debtAmountController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Enter debt amount',
                                        ),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              final String enteredAmount =
                                                  _debtAmountController.text
                                                      .trim();
                                              debtAmount = double.tryParse(
                                                      enteredAmount) ??
                                                  0.0;
                                              if (debtAmount > 0.0) {
                                                selectedFriends.add({
                                                  'friendName': friendName,
                                                  'debtAmount': debtAmount,
                                                });
                                              }
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Text('Add'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedFriends.map((friend) {
                return Chip(
                  label: Text(
                      '${friend['friendName']} (${friend['debtAmount']} \$)'),
                  deleteIcon: Icon(Icons.clear),
                  onDeleted: () {
                    setState(() {
                      selectedFriends.remove(friend);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class AddReceiptButton extends StatefulWidget {
  @override
  _AddReceiptButtonState createState() => _AddReceiptButtonState();
}

class _AddReceiptButtonState extends State<AddReceiptButton> {
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    final reference = FirebaseStorage.instance
        .ref()
        .child('receipts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      final task = await reference.putFile(_imageFile!);
      final downloadUrl = await task.ref.getDownloadURL();

      // Perform further actions with the download URL (e.g., save to Firestore)
      print('Uploaded image URL: $downloadUrl');
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _pickImage(ImageSource.camera),
          child: Text('Take Photo'),
        ),
        ElevatedButton(
          onPressed: () => _pickImage(ImageSource.gallery),
          child: Text('Choose from Gallery'),
        ),
        if (_imageFile != null) ...[
          SizedBox(height: 16),
          Image.file(
            _imageFile!,
            height: 200,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _uploadImage,
            child: Text('Upload Receipt'),
          ),
        ],
      ],
    );
  }
}

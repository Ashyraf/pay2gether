import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RoomPage extends StatefulWidget {
  const RoomPage({Key? key}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();

  static Widget createRoomButton(BuildContext context) {
    final roomNameController = TextEditingController();
    final AddPeopleForm addPeopleForm = AddPeopleForm(context);

    return ElevatedButton(
      child: Text("Create a Room"),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Create a Room'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AddReceiptButton(
                      onReceiptImageSelected: (File imageFile) {
                        // Handle the selected receipt image here
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Room name',
                      ),
                      controller: roomNameController,
                    ),
                    SizedBox(height: 16),
                    addPeopleForm,
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    final roomName = roomNameController.text.trim();
                    final selectedFriends = addPeopleForm.getSelectedFriends();
                    final totalDebt = addPeopleForm.getTotalDebt();
                    final currentUser = FirebaseAuth.instance.currentUser;
                    final currentUserEmail = currentUser?.email;

                    if (currentUserEmail != null) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUserEmail)
                          .collection('debtRoom')
                          .add({
                        'roomName': roomName,
                        'roomMaster': currentUserEmail,
                        'selectedFriends': selectedFriends,
                        'totalDebt': totalDebt,
                        // Add other relevant data as needed
                      }).then((value) {
                        // Success
                        print('Room created successfully!');
                      }).catchError((error) {
                        // Error
                        print('Failed to create room: $error');
                      });
                    }

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
  final BuildContext context;

  AddPeopleForm(this.context);

  @override
  _AddPeopleFormState createState() => _AddPeopleFormState();

  List<Map<String, dynamic>> getSelectedFriends() {
    final _AddPeopleFormState? state =
        context.findAncestorStateOfType<_AddPeopleFormState>();
    return state?.selectedFriends ?? [];
  }

  double getTotalDebt() {
    final _AddPeopleFormState? state =
        context.findAncestorStateOfType<_AddPeopleFormState>();
    return state?.totalDebt ?? 0.0;
  }
}

class _AddPeopleFormState extends State<AddPeopleForm> {
  User? currentUser;
  List<Map<String, dynamic>> _friendList = [];
  List<Map<String, dynamic>> selectedFriends = [];
  Map<String, dynamic>? selectedFriendWithDebt;
  double totalDebt = 0.0;
  final _debtAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    fetchFriendList();
  }

  Future<void> fetchFriendList() async {
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
      selectedFriendWithDebt!['status'] = 'pending';
      selectedFriends.add(selectedFriendWithDebt!);
      selectedFriendWithDebt = null;
      _debtAmountController.clear();
      calculateTotalDebt();
    }
  }

  void calculateTotalDebt() {
    totalDebt =
        selectedFriends.fold(0.0, (sum, friend) => sum + friend['debtAmount']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select friends:'),
        SizedBox(height: 8),
        DropdownButton<Map<String, dynamic>>(
          value: selectedFriendWithDebt,
          hint: Text('Select a friend'),
          items: _friendList.map((friend) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: friend,
              child: Text(friend['name']),
            );
          }).toList(),
          onChanged: (friend) {
            setState(() {
              selectedFriendWithDebt = friend;
            });
          },
        ),
        SizedBox(height: 8),
        Text('Debt amount:'),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _debtAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter debt amount',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: addFriendWithDebt,
              child: Text('Add Friend'),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text('Selected friends with debt:'),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: selectedFriends.length,
          itemBuilder: (BuildContext context, int index) {
            final friend = selectedFriends[index];
            return ListTile(
              title: Text(friend['name']),
              subtitle: Text('Debt: ${friend['debtAmount']}'),
            );
          },
        ),
        SizedBox(height: 8),
        Text('Total debt: $totalDebt'),
      ],
    );
  }
}

class AddReceiptButton extends StatefulWidget {
  final void Function(File imageFile) onReceiptImageSelected;

  const AddReceiptButton({Key? key, required this.onReceiptImageSelected})
      : super(key: key);

  @override
  _AddReceiptButtonState createState() => _AddReceiptButtonState();
}

class _AddReceiptButtonState extends State<AddReceiptButton> {
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        widget.onReceiptImageSelected(_imageFile!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add receipt:'),
        SizedBox(height: 8),
        if (_imageFile != null) ...[
          Image.file(_imageFile!),
          SizedBox(height: 8),
        ],
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                _pickImage(ImageSource.camera);
              },
              child: Icon(Icons.camera_alt),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _pickImage(ImageSource.gallery);
              },
              child: Icon(Icons.photo_library),
            ),
          ],
        ),
      ],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RoomPage(),
    );
  }
}

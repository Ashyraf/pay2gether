import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RoomPage extends StatefulWidget {
  const RoomPage({Key? key}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();

  static Widget createRoomButton(BuildContext context) {
    final roomNameController = TextEditingController();

    // Initialize selectedFriends list
    List<Map<String, dynamic>> selectedFriends = [];

    // Function to add friend with debt to selectedFriends
    void addFriendWithDebt(Map<String, dynamic> friend) {
      friend['status'] = 'pending';
      selectedFriends.add(friend);
    }

    // Calculate total debt
    double calculateTotalDebt() {
      return selectedFriends.fold(
          0.0, (sum, friend) => sum + friend['debtAmount']);
    }

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
                    AddPeopleForm(
                      selectedFriends: selectedFriends,
                      addFriendWithDebt: addFriendWithDebt,
                      calculateTotalDebt: calculateTotalDebt,
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    final roomName = roomNameController.text.trim();
                    final currentUser = FirebaseAuth.instance.currentUser;
                    final currentUserEmail = currentUser?.email;

                    FirebaseFirestore.instance
                        .collection('debtRoom')
                        .doc(roomName) // Use roomName as the document ID
                        .set({
                      'roomName': roomName,
                      'roomMaster': currentUserEmail,
                      'selectedFriends': selectedFriends.map((friend) {
                        return {
                          'friendName': friend['friendName'],
                          'debtAmount': friend['debtAmount'],
                          'status': 'pending',
                        };
                      }).toList(),
                      'totalDebt': calculateTotalDebt(),
                      // Add other relevant data as needed
                    }).then((value) {
                      // Success
                      print('Room created successfully!');
                    }).catchError((error) {
                      // Error
                      print('Failed to create room: $error');
                    });

                    Navigator.pop(context);
                  },
                  child: Text('Create'),
                ),
                ElevatedButton(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoomPage.createRoomButton(context),
          ],
        ),
      ),
    );
  }
}

class AddPeopleForm extends StatefulWidget {
  final List<Map<String, dynamic>> selectedFriends;
  final Function addFriendWithDebt;
  final Function calculateTotalDebt;

  const AddPeopleForm({
    Key? key,
    required this.selectedFriends,
    required this.addFriendWithDebt,
    required this.calculateTotalDebt,
  }) : super(key: key);

  @override
  _AddPeopleFormState createState() => _AddPeopleFormState();
}

class _AddPeopleFormState extends State<AddPeopleForm> {
  final _friendNameController = TextEditingController();
  final _debtAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Friend Name',
          ),
          controller: _friendNameController,
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Debt Amount',
          ),
          controller: _debtAmountController,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final friendName = _friendNameController.text.trim();
            final debtAmount =
                double.tryParse(_debtAmountController.text) ?? 0.0;

            if (friendName.isNotEmpty && debtAmount > 0) {
              final friend = {
                'friendName': friendName,
                'debtAmount': debtAmount,
              };

              // Call the addFriendWithDebt function from the parent widget
              widget.addFriendWithDebt(friend);

              // Clear the text fields
              _friendNameController.clear();
              _debtAmountController.clear();

              // Rebuild the parent widget to update the total debt display
              setState(() {});
            }
          },
          child: Text('Add Friend'),
        ),
        SizedBox(height: 16),
        Text('Total Debt: \$${widget.calculateTotalDebt().toStringAsFixed(2)}'),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.selectedFriends.length,
          itemBuilder: (BuildContext context, int index) {
            final friend = widget.selectedFriends[index];
            return ListTile(
              title: Text(friend['friendName']),
              subtitle: Text('\$${friend['debtAmount'].toStringAsFixed(2)}'),
            );
          },
        ),
      ],
    );
  }
}

class AddReceiptButton extends StatelessWidget {
  final Function(File) onReceiptImageSelected;

  const AddReceiptButton({Key? key, required this.onReceiptImageSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final ImagePicker _picker = ImagePicker();
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final imageFile = File(image.path);
          onReceiptImageSelected(imageFile);
        }
      },
      child: Text('Add Receipt'),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RoomPage(),
  ));
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Room name',
                    ),
                  ),
                  SizedBox(height: 16),
                  AddPeopleForm(),
                ],
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
  List<String> selectedFriends = [];

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getFriendList();
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity, // Set a specific width constraint
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add people:'),
            SizedBox(height: 8),
            if (_friendList.isNotEmpty)
              SizedBox(
                width: 300, // Adjust the width as needed
                height: 200, // Adjust the height as needed
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _friendList.length,
                  itemBuilder: (context, index) {
                    final friend = _friendList[index];

                    return Card(
                      child: ListTile(
                        title: Text(friend['friendName'] ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              selectedFriends.add(friend['friendName']);
                            });
                          },
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
                  label: Text(friend),
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

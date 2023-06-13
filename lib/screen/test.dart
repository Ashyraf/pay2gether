import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../reusable_widget/reuse.dart';

class Friend extends StatefulWidget {
  const Friend({Key? key}) : super(key: key);

  @override
  State<Friend> createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  final _usernameController = TextEditingController();
  List<String> _usernames = [];
  List<Map<String, dynamic>> _friendList = [];
  late String currentUserID;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getFriendList();
  }

  Future<void> getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    currentUserID = currentUser?.email ?? '';
  }

  Future<void> searchUsername(String username) async {
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    final usernames =
        userQuery.docs.map((doc) => doc['username'] as String).toList();

    setState(() {
      _usernames = usernames;
    });
  }

  Future<void> requestFriendship(String username) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserEmail = currentUser?.email;
    final currentUserUsername = currentUser?.displayName ?? '';

    setState(() {
      _usernames = ['Loading...'];
    });

    try {
      final recipientQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (recipientQuery.docs.isNotEmpty) {
        final recipientDoc = recipientQuery.docs.first;
        final recipientEmail = recipientDoc['email'];

        final recipientRef =
            FirebaseFirestore.instance.collection('users').doc(recipientEmail);
        await recipientRef.update({
          'friendRequests': FieldValue.arrayUnion([
            {
              'userID': currentUserEmail,
              'senderUsername': currentUserUsername,
              'receiverEmail': recipientEmail,
            }
          ])
        });
      }

      setState(() {
        _usernames = [];
      });
    } catch (error) {
      print('Error requesting friendship: $error');
      setState(() {
        _usernames = ['Error: Failed to send request'];
      });
    }
  }

  Future<void> getFriendList() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserEmail = currentUser?.email;

    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUserEmail)
        .get();

    final userDoc = userQuery.docs.first;
    final friendList = userDoc['friendList'] as List<dynamic>;

    setState(() {
      _friendList = List<Map<String, dynamic>>.from(friendList);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'FWIENDS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _friendList.length,
              itemBuilder: (context, index) {
                final friend = _friendList[index];
                final friendName = friend['friendName'] as String;

                return Card(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(friendName),
                    trailing: IconButton(
                      icon: Icon(Icons.chat),
                      onPressed: () {
                        // Implement chat functionality
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyDrawerList(
                usernameController: _usernameController,
                usernames: _usernames,
                onUsernameChanged: searchUsername,
                onFriendRequest: requestFriendship,
                currentUserID: currentUserID.isNotEmpty ? currentUserID : '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget appbar() {
    return AppBar(
      title: logoWidget("assets/images/applogosmall.png"),
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.grey,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
        color: Colors.black,
      ),
      actions: [
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              color: Colors.black,
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ],
    );
  }
}

class MyDrawerList extends StatelessWidget {
  final TextEditingController usernameController;
  final List<String> usernames;
  final Function(String) onUsernameChanged;
  final Function(String) onFriendRequest;
  final String currentUserID;

  MyDrawerList({
    required this.usernameController,
    required this.usernames,
    required this.onUsernameChanged,
    required this.onFriendRequest,
    required this.currentUserID,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          TextField(
            controller: usernameController,
            onChanged: onUsernameChanged,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              hintText: "Insert your friend's username",
              prefixIcon: Icon(Icons.search),
              prefixIconColor: Colors.black,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: usernames.length,
            itemBuilder: (context, index) {
              final username = usernames[index];
              return Card(
                child: ListTile(
                  title: Text(username),
                  trailing: ElevatedButton(
                    onPressed: () => onFriendRequest(username),
                    child: Text('Request'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

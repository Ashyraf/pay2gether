import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pay2gether/Design/Drawer/custom_drawer.dart';
import 'package:pay2gether/reusable_widget/reusev2.dart';
import 'searchDrawer.dart';

class Friend extends StatefulWidget {
  const Friend({Key? key}) : super(key: key);

  @override
  State<Friend> createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  Future<void> acceptFriendRequest(
      String friendUsername, String friendEmail) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserEmail = currentUser?.email;

    try {
      final currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserEmail);
      final currentUserDoc = await currentUserRef.get();

      if (currentUserDoc.exists) {
        final friendRequests =
            currentUserDoc['friendRequests'] as List<dynamic>;

        final updatedFriendRequests = friendRequests
            .where((request) => request['senderUsername'] != friendUsername)
            .toList();

        await currentUserRef.update({
          'friendRequests': updatedFriendRequests,
          'friends': FieldValue.arrayUnion([friendEmail])
        });

        final friendRef =
            FirebaseFirestore.instance.collection('users').doc(friendEmail);
        final friendDoc = await friendRef.get();

        if (friendDoc.exists) {
          final friendFriendRequests =
              friendDoc['friendRequests'] as List<dynamic>;

          final updatedFriendFriendRequests = friendFriendRequests
              .where((request) => request['senderUsername'] != currentUserEmail)
              .toList();

          await friendRef.update({
            'friendRequests': updatedFriendFriendRequests,
            'friends': FieldValue.arrayUnion([currentUserEmail])
          });
        }
      }
    } catch (error) {
      print('Error accepting friend request: $error');
    }
  }

  Future<void> rejectFriendRequest(String friendUsername) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserEmail = currentUser?.email;

    try {
      final currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserEmail);
      final currentUserDoc = await currentUserRef.get();

      if (currentUserDoc.exists) {
        final friendRequests =
            currentUserDoc['friendRequests'] as List<dynamic>;

        final updatedFriendRequests = friendRequests
            .where((request) => request['senderUsername'] != friendUsername)
            .toList();

        await currentUserRef.update({
          'friendRequests': updatedFriendRequests,
        });
      }
    } catch (error) {
      print('Error rejecting friend request: $error');
    }
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
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: reusableAppBarFriend(_scaffoldKey, context),
      drawer: const CustomDrawer(),
      body: Container(
        decoration: decorationWithBackground(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'FWIENDS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Set text color to black
                  fontStyle: FontStyle.italic, // Set font style to italic
                  fontFamily: 'Math Sans', // Set custom font
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _friendList.length,
                itemBuilder: (context, index) {
                  final friend = _friendList[index];

                  return Card(
                    child: ListTile(
                      title: Text(friend['friendName'] ?? ''),
                      trailing: IconButton(
                        icon: Icon(Icons.chat),
                        onPressed: () {
                          // Perform the action when the chat icon button is pressed
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SearchDrawer(
                usernameController: _usernameController,
                usernames: _usernames,
                onUsernameChanged: searchUsername,
                onFriendRequest: requestFriendship,
                onAcceptRequest: acceptFriendRequest,
                onRejectRequest: rejectFriendRequest,
                currentUserID: currentUserID,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

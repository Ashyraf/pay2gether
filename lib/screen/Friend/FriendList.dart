// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Friendlist extends StatefulWidget {
  const Friendlist({super.key});

  @override
  State<Friendlist> createState() => _FriendlistState();
}

class _FriendlistState extends State<Friendlist> {
  late String currentUsername;
  List<Map<String, dynamic>> _friendList = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    currentUsername = user != null ? user.displayName ?? '' : '';
    getFriendList(); // Call this method to populate the friend list.
  }

  Future<void> getFriendList() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUsername = currentUser?.displayName;

    final userDoc = await FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUsername)
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
    if (_friendList.isEmpty) {
      // If the friend list is empty, return nothing.
      return SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friends')
          .doc(currentUsername)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        final userDocument = snapshot.data;

        if (!userDocument!.exists) {
          return Text('No friends yet.');
        }

        final friends = userDocument['friendLists'] as List<dynamic>;

        if (friends.isEmpty) {
          return Text('No friends yet.');
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index] as Map<String, dynamic>;
            final friendName = friend['friendName'] as String?;
            final friendEmail = friend['friendEmail'] as String?;

            if (friendName == null || friendEmail == null) {
              return Text('Error: Friend data not found');
            }

            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(friendName),
                subtitle: Text(friendEmail),
              ),
            );
          },
        );
      },
    );
  }
}

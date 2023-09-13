import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pay2gether/reusable_widget/reuse.dart';

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
      appBar: appbar(),
      body: Column(
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
      endDrawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyDrawerList(
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
  final Function(String, String) onAcceptRequest;
  final Function(String) onRejectRequest;
  final String currentUserID;

  MyDrawerList({
    required this.usernameController,
    required this.usernames,
    required this.onUsernameChanged,
    required this.onFriendRequest,
    required this.onAcceptRequest,
    required this.onRejectRequest,
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
          SizedBox(height: 20),
          Text(
            'Friend Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserID)
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
                return Text('No friend requests');
              }

              final friendRequests =
                  userDocument['friendRequests'] as List<dynamic>;

              if (friendRequests.isEmpty) {
                return Text('No friend requests');
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: friendRequests.length,
                itemBuilder: (context, index) {
                  final request = friendRequests[index] as Map<String, dynamic>;
                  final senderUsername = request['senderUsername'] as String?;

                  // Check if senderUsername is null before using it
                  if (senderUsername == null) {
                    return Text('Error: Sender username not found');
                  }
                  return ListTile(
                    title: Text(senderUsername),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Accept friend request
                            // Implement the logic to accept the friend request
                            // For example, you can update the user's friend list
                            // and remove the request from the friendRequests list

                            final friendRequest =
                                friendRequests[index] as Map<String, dynamic>;
                            final senderUsername =
                                friendRequest['senderUsername'] as String?;
                            final senderEmail =
                                friendRequest['userID'] as String?;

                            if (senderUsername != null && senderEmail != null) {
                              // Add friend to the user's friend list
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUserID)
                                  .update({
                                'friendLists': FieldValue.arrayUnion([
                                  {
                                    'friendName': senderUsername,
                                    'friendEmail': senderEmail
                                  }
                                ])
                              });

                              // Remove the friend request from the list
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUserID)
                                  .update({
                                'friendRequests':
                                    FieldValue.arrayRemove([friendRequest])
                              });
                            }

                            // After accepting, you may want to update the UI to reflect the change
                          },
                          child: Text('Accept'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            // Reject friend request
                            // Implement the logic to reject the friend request
                            // For example, you can remove the request from the friendRequests list

                            final currentUserID =
                                FirebaseAuth.instance.currentUser?.email;
                            final senderUsername =
                                request['senderUsername'] as String?;

                            if (currentUserID != null &&
                                senderUsername != null) {
                              final userRef = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUserID);

                              await FirebaseFirestore.instance
                                  .runTransaction((transaction) async {
                                final userSnapshot =
                                    await transaction.get(userRef);

                                if (userSnapshot.exists) {
                                  final friendRequests =
                                      userSnapshot.data()?['friendRequests'] ??
                                          [];

                                  // Find the index of the friend request to remove
                                  final index = friendRequests.indexWhere(
                                      (request) =>
                                          request['senderUsername'] ==
                                          senderUsername);

                                  if (index != -1) {
                                    // Remove the friend request from the array
                                    friendRequests.removeAt(index);

                                    // Update the friendRequests field in Firestore
                                    transaction.update(userRef,
                                        {'friendRequests': friendRequests});
                                  }
                                }
                              });
                            }

                            // After rejecting, you may want to update the UI to reflect the change
                          },
                          child: Text('Reject'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}

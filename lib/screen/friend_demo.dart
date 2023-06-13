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
  late String currentUserID;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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
    final currentUserID =
        currentUser?.email; // Use the current user's email as the ID
    final currentUserUsername =
        currentUser?.displayName ?? ''; // Use the current user's username

    setState(() {
      // Show a loading indicator while the request is being processed
      _usernames = ['Loading...'];
    });

    try {
      final recipientQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (recipientQuery.docs.isNotEmpty) {
        final recipientDoc = recipientQuery.docs.first;
        final recipientID = recipientDoc.id;

        final recipientRef =
            FirebaseFirestore.instance.collection('users').doc(recipientID);
        await recipientRef.update({
          'friendRequests': FieldValue.arrayUnion([
            {
              'userID': currentUserID,
              'senderUsername': currentUserUsername,
              // Add any other user information you want to store in the friend request
            }
          ])
        });
      }

      setState(() {
        // Clear the loading indicator and update the list of usernames
        _usernames = [];
      });
    } catch (error) {
      print('Error requesting friendship: $error');

      setState(() {
        // Show an error message in the list of usernames
        _usernames = ['Error: Failed to send request'];
      });
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
      body: Container(),
      endDrawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyDrawerList(
                usernameController: _usernameController,
                usernames: _usernames,
                onUsernameChanged: searchUsername,
                onFriendRequest: requestFriendship,
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
          SizedBox(height: 20),
          Text(
            'Friend Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('friendRequests.senderUsername',
                    isEqualTo: currentUserID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              final userDocuments = snapshot.data?.docs;

              if (userDocuments == null || userDocuments.isEmpty) {
                return Text('No friend requests');
              }

              final friendRequests = userDocuments
                  .map((doc) => doc['friendRequests'] as List<dynamic>)
                  .expand((requests) => requests)
                  .toList();

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
                            // and remove the request from the friendRequests field

                            // After accepting, you may want to update the UI to reflect the change
                          },
                          child: Text('Accept'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Reject friend request
                            // Implement the logic to reject the friend request
                            // For example, you can remove the request from the friendRequests field

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

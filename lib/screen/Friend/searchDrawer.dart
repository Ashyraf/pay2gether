import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchDrawer extends StatefulWidget {
  const SearchDrawer({
    Key? key,
    required this.usernameController,
    required this.usernames,
    required this.onUsernameChanged,
    required this.onFriendRequest,
    required this.onAcceptRequest,
    required this.onRejectRequest,
    required this.currentUserID,
  }) : super(key: key);

  final TextEditingController usernameController;
  final List<String> usernames;
  final Function(String) onUsernameChanged;
  final Function(String) onFriendRequest;
  final Function(String, String) onAcceptRequest;
  final Function(String) onRejectRequest;
  final String currentUserID;

  @override
  State<SearchDrawer> createState() => _SearchDrawerState();
}

class _SearchDrawerState extends State<SearchDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          TextField(
            controller: widget.usernameController,
            onChanged: widget.onUsernameChanged,
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
            itemCount: widget.usernames.length,
            itemBuilder: (context, index) {
              final username = widget.usernames[index];
              return Card(
                child: ListTile(
                  title: Text(username),
                  trailing: ElevatedButton(
                    onPressed: () => widget.onFriendRequest(username),
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
                .doc(widget.currentUserID)
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
                                  .doc(widget.currentUserID)
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
                                  .doc(widget.currentUserID)
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
                                  .doc(widget.currentUserID);

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

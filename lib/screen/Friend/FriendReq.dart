import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest extends StatefulWidget {
  const FriendRequest({super.key});

  @override
  State<FriendRequest> createState() => _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {
  late String currentUserEmail;
  late String currentUsername;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    currentUserEmail = user != null ? user.email ?? '' : '';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friends')
          .doc(currentUserEmail)
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

        final friendRequests = userDocument['friendRequests'] as List<dynamic>;

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
            return Card(
              elevation: 4, // Adjust the elevation as needed
              margin: EdgeInsets.all(8), // Adjust the margin as needed
              child: ListTile(
                title: Text(senderUsername),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final currentUserEmail =
                            FirebaseAuth.instance.currentUser?.email;
                        final user = FirebaseAuth.instance.currentUser;
                        final currentUserDisplayName = user!.displayName;
                        if (currentUserEmail != null) {
                          final senderUsername =
                              request['senderUsername'] as String?;
                          final friendEmail = request['senderEmail'] as String?;

                          if (senderUsername != null && friendEmail != null) {
                            try {
                              // Create a batch for multiple Firestore operations
                              WriteBatch batch =
                                  FirebaseFirestore.instance.batch();

                              final currentUserRef = FirebaseFirestore.instance
                                  .collection('friends')
                                  .doc(currentUserEmail);
                              final friendRef = FirebaseFirestore.instance
                                  .collection('friends')
                                  .doc(friendEmail);

                              // Remove the friend request from the current user's friendRequests
                              batch.update(currentUserRef, {
                                'friendRequests': FieldValue.arrayRemove([
                                  {
                                    'receiverEmail': currentUserEmail,
                                    'senderUsername': senderUsername,
                                    'senderEmail': friendEmail,
                                  }
                                ])
                              });

                              // Add sender to the current user's friend list
                              print(
                                  'Adding sender to current user\'s friend list'); // Add this line for debugging
                              batch.update(currentUserRef, {
                                'friendLists': FieldValue.arrayUnion([
                                  {
                                    'friendName': senderUsername,
                                    'friendEmail': friendEmail,
                                  }
                                ])
                              });

                              print(
                                  'Adding current user to sender\'s friend list'); // Add this line for debugging
                              batch.update(friendRef, {
                                'friendLists': FieldValue.arrayUnion([
                                  {
                                    'friendName': currentUserDisplayName,
                                    'friendEmail': currentUserEmail,
                                  }
                                ])
                              });
                              await batch.commit();
                              setState(() {});
                            } catch (error) {
                              print('Error accepting friend request: $error');
                            }
                          }
                        }
                      },
                      child: Text('Accept'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        // Reject friend request
                        // Implement the logic to reject the friend request
                        // For example, you can remove the request from the friendRequests list

                        final currentUserEmail =
                            FirebaseAuth.instance.currentUser?.email;
                        final senderUsername =
                            request['senderUsername'] as String?;

                        if (currentUserEmail != null &&
                            senderUsername != null) {
                          final userRef = FirebaseFirestore.instance
                              .collection('friends')
                              .doc(currentUserEmail);

                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            final userSnapshot = await transaction.get(userRef);

                            if (userSnapshot.exists) {
                              final friendRequests =
                                  userSnapshot.data()?['friendRequests'] ?? [];

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
              ),
            );
          },
        );
      },
    );
  }
}

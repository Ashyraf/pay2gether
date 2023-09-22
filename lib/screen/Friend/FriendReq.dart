// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest extends StatefulWidget {
  const FriendRequest({Key? key});

  @override
  State<FriendRequest> createState() => _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {
  late String currentUsername;
  List<Map<String, dynamic>> _friendRequests = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    currentUsername = user != null ? user.displayName ?? '' : '';
    getFriendRequest();
  }

  Future<void> getFriendRequest() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUsername = currentUser?.displayName;

    final userDoc = await FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUsername)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null && data.containsKey('friendRequests')) {
        final friendRequests = data['friendRequests'] as List<dynamic>;

        setState(() {
          _friendRequests = friendRequests.cast<Map<String, dynamic>>();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_friendRequests.isEmpty) {
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

        final friendRequests =
            userDocument!['friendRequests'] as List<dynamic>?;

        if (friendRequests == null || friendRequests.isEmpty) {
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
                        final currentUsername =
                            FirebaseAuth.instance.currentUser?.displayName;
                        final currentUserEmail =
                            FirebaseAuth.instance.currentUser?.email;

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
                                  .doc(currentUsername);
                              final friendRef = FirebaseFirestore.instance
                                  .collection('friends')
                                  .doc(senderUsername);

                              // Remove the friend request from the current user's friendRequests
                              batch.update(currentUserRef, {
                                'friendRequests': FieldValue.arrayRemove([
                                  {
                                    'receiverUsername': currentUsername,
                                    'senderUsername': senderUsername,
                                    'senderEmail': friendEmail,
                                  }
                                ])
                              });

                              // Add sender to the current user's friend list
                              batch.update(currentUserRef, {
                                'friendLists': FieldValue.arrayUnion([
                                  {
                                    'friendName': senderUsername,
                                    'friendEmail': friendEmail,
                                  }
                                ])
                              });

                              // Check if the document for senderUsername exists
                              final senderDocRef = FirebaseFirestore.instance
                                  .collection('friends')
                                  .doc(senderUsername);

                              final senderDoc = await senderDocRef.get();

                              if (!senderDoc.exists) {
                                // Create a document for the sender
                                batch.set(senderDocRef, {
                                  'friendLists': [
                                    {
                                      'friendName': currentUsername,
                                      'friendEmail': currentUserEmail,
                                    }
                                  ],
                                  // You can add other fields as needed
                                });
                              }

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

                        final currentUsername =
                            FirebaseAuth.instance.currentUser?.displayName;
                        final senderUsername =
                            request['senderUsername'] as String?;

                        if (currentUsername != null && senderUsername != null) {
                          final userRef = FirebaseFirestore.instance
                              .collection('friends')
                              .doc(currentUsername);

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

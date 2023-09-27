import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class searchFriend extends SearchDelegate {
  List<String> searchTerms = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No results found.');
        } else {
          final usernames = snapshot.data!.docs
              .map((doc) => doc['username'] as String)
              .where((username) =>
                  username !=
                  FirebaseAuth.instance.currentUser
                      ?.displayName) // Exclude current user's username
              .toList();
          return ListView.builder(
            itemBuilder: (context, index) {
              final result = usernames[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(result) // Assuming 'result' is the username
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (userSnapshot.hasError) {
                    return Text('Error: ${userSnapshot.error}');
                  } else if (!userSnapshot.hasData) {
                    return SizedBox.shrink(); // No user data found
                  } else {
                    final profileImageUrl =
                        userSnapshot.data!['profileImageUrl'] as String;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profileImageUrl.isEmpty
                            ? null
                            : NetworkImage(profileImageUrl),
                        backgroundColor: Colors.white,
                      ),
                      title: Text(result),
                      trailing: ElevatedButton(
                        onPressed: () {
                          sendFriendRequest(result);
                        },
                        child: Text('Request'),
                      ),
                    );
                  }
                },
              );
            },
            itemCount: usernames.length,
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? [] // Show an empty list when there is no query
        : searchTerms
            .where((username) =>
                username.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final suggestion = suggestionList[index];
        return ListTile(
          title: Text(suggestion),
          trailing: ElevatedButton(
            onPressed: () {},
            child: Text('Request'),
          ),
        );
      },
    );
  }

  Future<void> sendFriendRequest(String receiverUsername) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final senderUsername = currentUser!.displayName;
    final senderEmail = currentUser.email;

    final friendRequestsCollection =
        FirebaseFirestore.instance.collection('friends');

    // Get a reference to the receiver's document
    final receiverDocRef = friendRequestsCollection.doc(receiverUsername);

    // Use a transaction to handle the creation of 'friendRequests' field
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(receiverDocRef);

      final data = docSnapshot.data();

      if (data == null || !data.containsKey('friendRequests')) {
        // If 'friendRequests' field doesn't exist or is null, create it
        transaction.update(receiverDocRef, {'friendRequests': []});
      }

      // Now, you can proceed to add the friend request as before
      final newFriendRequest = {
        'senderUsername': senderUsername,
        'senderEmail': senderEmail,
        'receiverUsername': receiverUsername,
      };

      // Update the friendRequests array by adding the new friend request
      final updatedFriendRequests = [
        ...(data?['friendRequests'] ?? []),
        newFriendRequest
      ];

      // Set the updated array back to the document
      transaction
          .update(receiverDocRef, {'friendRequests': updatedFriendRequests});
    });
  }
}


// 2. another one is that check
// from the collection (friends) 
//doc (current user) there is a field array friendLists 
//containing map of friendName and friendEmail inside the doc 
//of the currentUser. just get the friendName. if there is friendName 
//and the search user exist then the request button will chnage to Friend and
// cannot 
//be pressed.
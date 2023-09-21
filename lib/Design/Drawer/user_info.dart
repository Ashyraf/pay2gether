import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pay2gether/screen/HomeMain/profile_page.dart';
import 'package:pay2gether/screen/LoginRegister/login.dart';

class BottomUserInfo extends StatefulWidget {
  final bool isCollapsed;

  const BottomUserInfo({
    Key? key,
    required this.isCollapsed,
  }) : super(key: key);

  @override
  State<BottomUserInfo> createState() => _BottomUserInfoState();
}

class _BottomUserInfoState extends State<BottomUserInfo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? profileImageUrl;
  String? _username;
  @override
  void initState() {
    super.initState();
    // Load user data from Firestore
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserEmail = user.email!;
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(currentUserEmail).get();

      if (userDoc.exists) {
        setState(() {
          _username = userDoc.data()?['username'] as String? ?? '';
          profileImageUrl = userDoc.data()?['profileImageUrl'] as String? ?? '';
        });
      } else {
        // User document does not exist, display a white circle or default image
        setState(() {
          _username = userDoc.data()?['username'] as String? ?? '';
          // Set username to empty or a default value
          profileImageUrl =
              "assets/images/noprofileimage.png"; // Set profileImageUrl to empty or a default URL
        });
      }
    }
  }

  Widget build(BuildContext context) {
    final username = _username;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: widget.isCollapsed ? 100 : 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: widget.isCollapsed
          ? Center(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(), // Navigate to the ProfilePage
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 60,
                        height: 60,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: profileImageUrl!.isNotEmpty
                              ? NetworkImage(profileImageUrl!)
                              : null,
                          child: profileImageUrl!.isEmpty
                              ? Icon(Icons.person, size: 30, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              '$username',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: IconButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut().then((value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        });
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 60,
                    height: 60,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: profileImageUrl!.isNotEmpty
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl!.isEmpty
                          ? Icon(Icons.person, size: 30, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut().then((value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      });
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class search extends StatefulWidget {
//   const search({super.key});

//   @override
//   State<search> createState() => _searchState();
// }

// class _searchState extends State<search> {
//     TextEditingController searchController = new TextEditingController();

//   bool haveUserSearched = false;
//   late Future<dynamic> searchResult = getUserByUsername(searchController.text);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("search for user"),
//         centerTitle: true,
//       ),
//       body: Container(
//         child: Column(
//           children: [
//             Container(
//               color: Color(0xfffffefa),
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: searchController,
//                       style: TextStyle(color: Color(0xffBFBBB7)),
//                       onSubmitted: (value) {
//                         searchResult = getUserByUsername(searchController.text);
//                         setState(() {});
//                       },
//                       decoration: InputDecoration(
//                         hintText: "search by username",
//                         hintStyle: TextStyle(color: Color(0xffBFBBB7)),
//                         border: InputBorder.none,
//                         prefixIcon: Icon(
//                           Icons.search,
//                           color: Color(0xffBFBBB7),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             FutureBuilder(
//               future: searchResult,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   return userList(snapshot.data);
//                 }

//                 return Text("handle other state");
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   //-------methods and widgets-------
//   getUserByUsername(String username) async {
//     final result  = await FirebaseFirestore.instance
//         .collection('users')
//         .where('name', isEqualTo: username)
//         .get();
//    User myUser = User(name: result['name'] .....)  //get user from Map.. it cant be..
//    return myUser;  
//   }

//   Widget userTile(String name, String username) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//       child: Row(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 name,
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               Text(
//                 username,
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               )
//             ],
//           ),
//           Spacer(),
//           GestureDetector(
//             onTap: () {
//               //sendMessage(userName);
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                   color: Colors.blue, borderRadius: BorderRadius.circular(24)),
//               child: Text(
//                 "Message",
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget userList(user) {
//     return haveUserSearched
//         ?  userTile(
//                 user.name,
//                 user.username,
//               )
//         : Container();
//   }
// }

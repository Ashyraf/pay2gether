// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:pay2gether/Design/Drawer/custom_drawer.dart';
import 'package:pay2gether/reusable_widget/reusev2.dart';
import 'package:pay2gether/screen/Friend/FriendList.dart';
import 'package:pay2gether/screen/Friend/FriendReq.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> isSelected = [true, false];
  int currentPageIndex = 0;
  late PageController _pageController;
  late List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pages = [Friendlist(), FriendRequest()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: reusableAppBarFriend(_scaffoldKey, context),
      drawer: const CustomDrawer(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.grey.withOpacity(0.4),
        onDestinationSelected: (int newIndex) {
          _pageController.animateToPage(
            newIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        indicatorColor: Color.fromARGB(223, 129, 131, 182),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.group_outlined),
            icon: Icon(Icons.group_outlined),
            label: 'Friend List',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_add),
            label: 'Friend Request',
          ),
        ],
      ),
      body: Container(
        decoration: decorationWithBackground(),
        child: PageView(
          controller: _pageController,
          onPageChanged: (int newIndex) {
            setState(() {
              currentPageIndex = newIndex;
            });
          },
          children: [
            Friendlist(),
            FriendRequest(),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: unused_field
import 'package:flutter/material.dart';
import 'package:pay2gether/Design/Drawer/custom_drawer.dart';
import 'package:pay2gether/reusable_widget/reusev2.dart';
import 'package:pay2gether/screen/MasterRoom/masterroomcard.dart';
import 'package:pay2gether/screen/RoomUser/roomcard.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> isSelected = [true, false];
  int currentPageIndex = 0;
  late PageController _pageController;
  late List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pages = [MasterRoomCard(), RoomCard()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: reusableAppBar(_scaffoldKey, context),
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
            selectedIcon: Icon(Icons.leaderboard_outlined),
            icon: Icon(Icons.leaderboard_outlined),
            label: 'Master Room',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Your Room',
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
            MasterRoomCard(),
            RoomCard(),
          ],
        ),
      ),
    );
  }
}

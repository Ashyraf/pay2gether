import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerState extends ChangeNotifier {
  bool _isCollapsed = true;

  bool get isCollapsed => _isCollapsed;

  void toggleDrawerState() {
    _isCollapsed = !isCollapsed;
    notifyListeners();
    saveDrawerState(_isCollapsed);
  }
}

Future<void> initDrawerState(DrawerState drawerState) async {
  final prefs = await SharedPreferences.getInstance();
  final isExpanded = prefs.getBool('isCollapsed') ?? false;
  drawerState._isCollapsed = isExpanded;
  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
  drawerState.notifyListeners();
}

Future<void> saveDrawerState(bool isCollapsed) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('isCollapsed', isCollapsed);
}

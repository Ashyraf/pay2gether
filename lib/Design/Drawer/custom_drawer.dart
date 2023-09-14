import 'package:flutter/material.dart';
import 'package:pay2gether/Design/Drawer/user_info.dart';
import 'package:provider/provider.dart';
import 'custom_list_tile.dart';
import 'drawer_state.dart';
import 'header.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final drawerState = context.watch<DrawerState>();
    return SafeArea(
      child: AnimatedContainer(
        curve: Curves.easeInOutCubic,
        duration: const Duration(milliseconds: 500),
        width: drawerState.isCollapsed ? 300 : 90,
        margin: const EdgeInsets.only(bottom: 10, top: 10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          color: Color.fromARGB(167, 49, 48, 48),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomDrawerHeader(isColapsed: drawerState.isCollapsed),
              const Divider(
                color: Colors.grey,
              ),
              CustomListTile(
                isCollapsed: drawerState.isCollapsed,
                icon: Icons.home_outlined,
                title: 'Home',
                infoCount: 0,
              ),
              CustomListTile(
                isCollapsed: drawerState.isCollapsed,
                icon: Icons.group_add,
                title: 'Friend',
                infoCount: 0,
              ),
              CustomListTile(
                isCollapsed: drawerState.isCollapsed,
                icon: Icons.add_home_rounded,
                title: 'Create Room',
                infoCount: 8,
              ),
              const SizedBox(height: 10),
              BottomUserInfo(isCollapsed: drawerState.isCollapsed),
              Align(
                alignment: drawerState.isCollapsed
                    ? Alignment.bottomRight
                    : Alignment.bottomCenter,
                child: IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(
                    drawerState.isCollapsed
                        ? Icons.arrow_back_ios
                        : Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: () {
                    setState(() {
                      drawerState.toggleDrawerState();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

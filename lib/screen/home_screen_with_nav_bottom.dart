import 'package:chat_flutter_final/screen/add_story.dart';
import 'package:chat_flutter_final/screen/profile_screen.dart';
import 'package:chat_flutter_final/screen/search_screen.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';

import '../widget/home_screen_widget.dart';
import 'list_user_screen.dart';
import 'online_screen.dart';

class HomeScreenWithNavBottom extends StatefulWidget {
  @override
  State<HomeScreenWithNavBottom> createState() => _HomeScreenWithNavBottomState();
}
class _HomeScreenWithNavBottomState extends State<HomeScreenWithNavBottom> {
  int currentPage = 0;
   String? groupChatId='';
   String? userId2='';
  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Center(
          child: _getPage(currentPage),
        ),
      ),
      bottomNavigationBar: FlashyTabBar(
        animationCurve: Curves.linear,
        selectedIndex: currentPage,
        showElevation: false, // use this to remove appBar's elevation
        onItemSelected: (index) => setState(() {
          currentPage = index;
        }),
        items: [
          FlashyTabBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
              activeColor: Colors.pink

          ),
          FlashyTabBarItem(
            icon: Icon(Icons.account_circle_outlined),
            title: Text('Online'),
            activeColor: Colors.pink
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.search_rounded),
            title: Text('Search'),
              activeColor: Colors.pink

          ),
          FlashyTabBarItem(
              icon: Icon(Icons.location_history),
              title: Text('Profile'),
              activeColor: Colors.pink

          ),


        ],
      ),

    );
  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return HomeScreenWidget();
      case 1:
        return OnlineScreen();
      case 2:
        return SearchScreen();
        case 3:
        return ProfileScreen();
      default:
        return HomeScreenWidget();
    }}
}
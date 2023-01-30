import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_flutter_final/widget/bottom_sheet_for_story_pick.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen_with_nav_bottom.dart';

class AddStory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddStoryState();
}

class _AddStoryState extends State<AddStory> with WidgetsBindingObserver {
  final _auth = FirebaseAuth.instance;
  late User signedInUser;

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void SetStatus(bool status) {
    FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'isStats': status,
    });
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
      }
    } catch (e) {
      print("Error getting current user: $e ");
    }
  }

  bool? _isConnected;

  void _checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty) {
        setState(() {
          _isConnected = true;
          SetStatus(true);
        });
      }
    } on SocketException catch (err) {
      setState(() {
        _isConnected = false;
        SetStatus(false);
      });
      if (kDebugMode) {
        print(err);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkInternetConnection();
    getCurrentUser();
    WidgetsBinding.instance.addObserver(this);
    SetStatus(true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isConnected == true) {
      SetStatus(true);
    } else {
      SetStatus(false);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SetStatus(false);
    super.dispose();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    SetStatus(false);

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final userData = FirebaseFirestore.instance.collection('users').snapshots();

    return Scaffold(
      appBar: PreferredSize(
        //wrap with PreferredSize
        preferredSize: Size.fromHeight(55),
        child: AppBar(
            elevation: 3,
            title: Text('Add Story'),
            centerTitle: true,
            actions: [
              Container(
                margin: EdgeInsets.only(right: 15),
                child: DropdownButton(
                  underline: Container(),
                  icon: Icon(Icons.menu,
                      color: Theme.of(context).primaryIconTheme.color,
                      size: 27),
                  items: [
                    DropdownMenuItem(
                      value: 'logout',
                      child: Row(
                        children: const [
                          Icon(
                            Icons.exit_to_app,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text('Logout'),
                        ],
                      ),
                    )
                  ],
                  onChanged: (itemIdentifier) async {
                    if (itemIdentifier == 'logout') {
                      SetStatus(false);
                      await FirebaseAuth.instance.signOut();
                    }
                  },
                ),
              ),
            ]),
      ),
      body: InkWell(
        onTap: () {
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (builder) => BottomSheetForStoryPick(),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/a.png',
                ),
              ),
              Container(
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (builder) => BottomSheetForStoryPick(),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Add Story',
                      style: TextStyle(
                        color: Colors.pink,
                        fontSize: 20,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

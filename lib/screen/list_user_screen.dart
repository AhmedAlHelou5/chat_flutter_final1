import 'dart:io';
import 'package:chat_flutter_final/widget/home_screen_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ListUserScreen extends StatefulWidget {
  final String groupChatId;
  final String userId2;
  final String type;

  ListUserScreen(this.groupChatId, this.userId2,this.type);

  @override
  State<ListUserScreen> createState() => _ListUserScreenState();
}

class _ListUserScreenState extends State<ListUserScreen>
    with WidgetsBindingObserver {

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
    return HomeScreenWidget();

  }
}

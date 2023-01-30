import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../widget/message.dart';
import '../widget/new_message.dart';
import 'auth_screen.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chat-screen';
  String image;
  String username;
  String userId2;
  String userId1;
  bool? isState;

  ChatScreen(
      this.username, this.image, this.userId2, this.userId1,
      {Key? key, this.isState})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  late User signedInUser;
  var currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String groupChatId = "";
  bool emojiShowing = false;
  final _scrollController = ScrollController();

  void SetStatus(bool status) {
    FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'isStats': status,
    });
  }


  bool? _isConnected;

  // This function is triggered when the floating button is pressed
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
    super.initState();
    final fbm = FirebaseMessaging.instance;
    _checkInternetConnection();
    fbm.requestPermission();
    FirebaseMessaging.onMessage.listen((message) {
      print(message);
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message);
      return;
    });
    fbm.subscribeToTopic('messages');
  }

  @override
  Widget build(BuildContext context) {
    String peerId = widget.userId2;
    if (_auth.currentUser!.uid.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }
    var chatRoomId = groupChatId;
    // FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(groupChatId)
    //     .update({'chattingWith': peerId});


    return Scaffold(
      appBar: PreferredSize(
        //wrap with PreferredSize
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                margin: EdgeInsets.only(top: 15), child: Text(widget.username)),
            Container(
                child: widget.isState!
                    ? Text(
                        'Online',
                        style: TextStyle(fontSize: 12, color: Colors.grey[350]),
                      )
                    : Text('Offline',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[350]))),
          ]),
          leading: Stack(children: [
            Positioned(
              top: 11,
              left: -5,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 40, top: 15),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.image),
              ),
            ),
            Positioned(
                top: 45,
                left: 70,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor:
                      widget.isState! ? Colors.green : Colors.green.withAlpha(0),
                )),
          ]),
          leadingWidth: 80,
        ),
      ),
      body: Container(
        // height: MediaQuery.of(context).size.height,
        // width: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Message(widget.isState!, chatRoomId, widget.userId2,
                  widget.userId1 == currentUserId ? true : false),
            ),
            NewMessage(widget.username, widget.image, widget.userId2,
                chatRoomId, widget.isState!),

          ],
        ),
      ),
    );
  }
}

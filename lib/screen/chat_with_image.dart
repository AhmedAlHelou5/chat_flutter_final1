import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatWithImageScreen extends StatefulWidget {
   final File? imageUrl;
  final String userName;
  final String groupChatId;
  final String userId2;

  ChatWithImageScreen(
      this.imageUrl, this.userName, this.groupChatId, this.userId2);

  @override
  State<ChatWithImageScreen> createState() => _ChatWithImageScreenState();
}

class _ChatWithImageScreenState extends State<ChatWithImageScreen> {
  final _controller = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String? _enteredMessage = '';

  bool? _isConnected;


  // void _sendMessage() async {
  //   final user = FirebaseAuth.instance.currentUser!;
  //   final userData = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid)
  //       .get();
  //   var currentUserId = user.uid;
  //   var peerId = widget.userId2;
  //
  //   try {
  //     final response = await InternetAddress.lookup('www.google.com');
  //     if (response.isNotEmpty) {
  //       setState(() {
  //         _isConnected = true;
  //         FirebaseFirestore.instance
  //             .collection('messages')
  //             .doc(widget.groupChatId)
  //             .collection(widget.groupChatId)
  //             .add({
  //           'text': _enteredMessage,
  //           'imageUrl': null,
  //           'file': null,
  //           'createdAt': Timestamp.now(),
  //           'username': userData['username'],
  //           'userId2': peerId,
  //           'userId1': currentUserId,
  //           'userImage': userData['image_url'],
  //           'isStats': userData['isStats'],
  //           'type': 'text',
  //         });
  //         _controller.clear();
  //         setState(() {
  //           _enteredMessage = '';
  //         });
  //       });
  //     }
  //   } on SocketException catch (err) {
  //     setState(() {
  //       _isConnected = false;
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Don’t Send because No Internet connection')));
  //
  //     });
  //     if (kDebugMode) {
  //       print(err);
  //     }
  //   }
  //
  //
  // }




  void _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    var currentUserId = user.uid;
    var peerId = widget.userId2;
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty) {
          final ref = FirebaseStorage.instance
              .ref().child('ChatRoom')
              .child(widget.groupChatId)
              .child('${DateTime
              .now()
              .millisecondsSinceEpoch}.jpg');

          await  ref.putFile(widget.imageUrl!);

          final url = await ref.getDownloadURL();

        await  FirebaseFirestore.instance
              .collection('messages')
              .doc(widget.groupChatId)
              .collection(widget.groupChatId)
              .add({
            'text': _enteredMessage ,
            'imageUrl': url,
            'file': null,
            'createdAt': Timestamp.now(),
            'username': userData['username'],
            'userId2': peerId,
            'userId1': currentUserId,
            'userImage': userData['image_url'],
            'isStats': userData['isStats'],
            'type': 'text and image',
          });

        await   FirebaseFirestore.instance
            .collection('last_message')
            .doc(user.uid)
            .collection(user.uid).doc(currentUserId)
            .set({
            'text': _enteredMessage,
            'timeSend': Timestamp.now(),
            'username': userData['username'],
            'userId2': peerId,
            'userId1': currentUserId,
            'userImage': userData['image_url'],
            'isStats': userData['isStats'],
            'type': 'text and image',});

          setState(()  {
            _isConnected = true;
          });

          _controller.clear();
          setState(() {
            _enteredMessage = '';
          });


      }
    } on SocketException catch (err) {
      setState(() {
        _isConnected = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Don’t Send because No Internet connection')));

      });
      if (kDebugMode) {
        print(err);
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(children: [
          Container(
            height: size.height,
            width: size.width,
            child: Image.file(
              widget.imageUrl!,
              height: size.height,
              width: size.width,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 10,
            child: Material(
              color: Colors.black,
              elevation: 6,
              child: Container(
                width: size.width,
                child: Row(
                  children: [
                    IconButton(
                      iconSize: size.height * 0.04,
                      icon: Icon(Icons.keyboard_backspace_outlined),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: size.width * 0.03,
                    ),
                    Text(
                      '${widget.userName}'.toUpperCase(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            child: Container(
              width: size.width,
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      margin: EdgeInsets.only(right: 10),
                      child: TextField(
                          controller: _controller,
                          autocorrect: true,
                          enableSuggestions: true,
                          textCapitalization: TextCapitalization.sentences,
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Send a message...',
                              hintStyle: TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(30)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(30))),
                              onChanged: (val) {
                            if (val.length > 0 && val != null) {
                              setState(() {
                                _enteredMessage = val;
                              });
                            } else {
                              setState(() {
                                _enteredMessage = '';
                              });
                            }
                          }
                          ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 1),
                    child: CircleAvatar(
                      backgroundColor: Colors.pink,
                      radius: 25,
                      child: IconButton(
                        color: Colors.white,
                        disabledColor: Colors.white70,
                        onPressed: (){
                          widget.imageUrl.toString().isEmpty
                            ? null
                            : _sendMessage();

                          setState(() async{
                            await FirebaseFirestore.instance
                                .collection('last_message')
                                .doc()
                                .collection(currentUserId).doc(currentUserId)
                                .update({
                              'text':_enteredMessage,
                              'type':'text and image',
                              'timeSend':Timestamp.now()
                            });
                          });
                          Navigator.of(context).pop();


                        },
                        icon: const Icon(Icons.send, size: 25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
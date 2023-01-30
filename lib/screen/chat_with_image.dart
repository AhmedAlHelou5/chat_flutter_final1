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
  void _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userDataLastMessage = await FirebaseFirestore.instance
        .collection('users').doc(widget.userId2)
        .get();
    var currentUserId = user.uid;
    var peerId = widget.userId2;
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty) {
          final ref = FirebaseStorage.instance
              .ref().child('ChatRoom')
              .child(widget.groupChatId)
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

          await  ref.putFile(widget.imageUrl!);

          final url = await ref.getDownloadURL();
          print(url);

        await  FirebaseFirestore.instance
              .collection('messages')
              .doc(widget.groupChatId)
              .collection(widget.groupChatId).doc(DateTime.now().millisecondsSinceEpoch.toString())
              .set({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
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
           'delete': false,
          'reaction': false,
          'isRead': false,



        });

        await   FirebaseFirestore.instance
            .collection('last_message')
            .doc(widget.groupChatId)
            .set({
            'text': _enteredMessage,
            'timeSend': Timestamp.now(),
            'username': userDataLastMessage['username'],
            'userId2': peerId,
            'userId1': currentUserId,
            'userImage': userDataLastMessage['image_url'],
          'isRead': false,

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
                            ?  _sendMessage()
                            :_sendMessage() ;
                          Navigator.of(context).pop();

                          // setState(() async{
                          //
                          //    await FirebaseFirestore.instance
                          //       .collection('last_message')
                          //       .doc('$currentUserId-${widget.userId2}')
                          //       .update({
                          //     'isRead':true,
                          //   });
                          //    final readMessage= await FirebaseFirestore.instance
                          //        .collection('messages')
                          //        .doc(widget.groupChatId).collection(wigroupChatId).doc(widget.id)
                          //        .update({
                          //      'delete': true,
                          //    });
                          //
                          // });
                          //

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
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:story_view/story_view.dart';

class UploadStoryScreen extends StatefulWidget{
  final File? imageUrl;
  final String userName;


  UploadStoryScreen(
      this.imageUrl, this.userName);

  @override
  State<StatefulWidget> createState() =>_UploadStoryScreenState();

}

class _UploadStoryScreenState extends State<UploadStoryScreen>{
  bool? _isConnected;

  void _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    var currentUserId = user.uid;
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty) {
        final ref = FirebaseStorage.instance
            .ref().child('stories')
            .child('${user.uid}').child('${DateTime
            .now()
            .millisecondsSinceEpoch}.png');
        await ref.putFile(widget.imageUrl!);
        final url = await ref.getDownloadURL();
        print(url);
        // List list=[];
        // list.add(url);
        Navigator.of(context).pop();

        await FirebaseFirestore.instance
              .collection('stories')
              .doc(currentUserId)
              .set({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'imageUrl': url,
            'createdAt': Timestamp.now(),
            'username': userData['username'],
            'userId1': currentUserId,
            'userImage': userData['image_url'],
            'isStats': userData['isStats'],
             'show': true,
            'type': 'image_story',
          });

        setState(() {
          _isConnected = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('uploaded')));
      }
    } on SocketException catch (err) {
      setState(() {
        _isConnected = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Don’t Send because No Internet connection')));
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
                        onPressed: _sendMessage,
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
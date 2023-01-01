import 'dart:io';
import 'package:chat_flutter_final/screen/chat_with_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

import '../screen/upload_story_screen.dart';

class BottomSheetUpdateImage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BottomSheetUpdateImageState();
}

class _BottomSheetUpdateImageState extends State<BottomSheetUpdateImage> {
  bool isLoading = true;
  File? file;
  var name;
  var value;
  String url = "";
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String imageUrl = "";

  bool? _isConnected;

  uploadFile(File? file) async {
    try {
      final _auth = FirebaseAuth.instance;
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      var currentUserId = user.uid;
      final response = await InternetAddress.lookup('www.google.com');
      try {
        if (response.isNotEmpty) {
          var imagefile = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child(currentUserId + '.jpg');
          ;
          UploadTask task = imagefile.putFile(file!);
          TaskSnapshot snapshot = await task;
          url = await snapshot.ref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .update({
            'image_url': url,
          });
          await FirebaseFirestore.instance
              .collection('stories')
              .doc(currentUserId)
              .update({
            'image_url': url,
          });
          await FirebaseFirestore.instance
              .collection('last_message')
              .doc(currentUserId)
              .collection(currentUserId).doc(currentUserId)
              .update({
            'image_url': url,
          });

          await  FirebaseFirestore.instance
              .collection('messages').doc(currentUserId).collection(currentUserId).
          where('userId1',isEqualTo: true).
          where('userId2',isEqualTo: true).get().then((value) async {
            await FirebaseFirestore.instance
                .collection('messages')
                .doc(currentUserId)
                .collection(currentUserId).doc(currentUserId).
            update({
              'image_url': url,
            });
          });


            if (url != null && file != null) {
            Fluttertoast.showToast(
              msg: "Done Uploaded",
              textColor: Colors.red,
            );
          } else {
            Fluttertoast.showToast(
              msg: "Something went wrong",
              textColor: Colors.red,
            );
          }
        }
      } on Exception catch (e) {
        Fluttertoast.showToast(
          msg: e.toString(),
          textColor: Colors.red,
        );
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.20,
      width: MediaQuery.of(context).size.width * 0.50,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      File? _pickedImage;
                      final ImagePicker _picker = ImagePicker();

                      final pickedImageFile =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (pickedImageFile != null) {
                        setState(() {
                          _pickedImage = File(pickedImageFile.path);
                          Navigator.of(context).pop();
                          uploadFile(_pickedImage);

                        });
                      } else {
                        print('No picked image');
                      }
                    },
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.pink,
                          child: Icon(
                            Icons.camera_alt,
                            // semanticLabel: "Help",
                            size: 29,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Camera',
                          style: TextStyle(
                            fontSize: 12,
                            // fontWeight: FontWeight.w100,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  InkWell(
                    onTap: () async {
                      File? _pickedImage;
                      final ImagePicker _picker = ImagePicker();
                      final user = FirebaseAuth.instance.currentUser!;
                      final userData = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get();

                      final pickedImageFile =
                          await _picker.getImage(source: ImageSource.gallery);
                      if (pickedImageFile != null) {
                        setState(() {
                          _pickedImage = File(pickedImageFile.path);
                          Navigator.of(context).pop();

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => UploadStoryScreen(
                                  _pickedImage!, userData['username'])));
                        });
                      } else {
                        print('No picked image');
                      }

                      print('image path: $imageUrl');
                    },
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.purple,
                          child: Icon(
                            Icons.insert_photo,
                            // semanticLabel: "Help",
                            size: 29,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 12,
                            // fontWeight: FontWeight.w100,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

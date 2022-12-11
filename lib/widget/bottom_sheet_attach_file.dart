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

class BottomSheetAttachFile extends StatefulWidget {
  final String groupChatId;
  final String username;
  final String image;
  final String userId2;

  BottomSheetAttachFile(
      this.groupChatId, this.username, this.image, this.userId2);

  @override
  State<BottomSheetAttachFile> createState() => _BottomSheetAttachFileState();
}

class _BottomSheetAttachFileState extends State<BottomSheetAttachFile> {
  bool isLoading = true;
  File? file;
  var name;
  var value;
  String url = "";

  String imageUrl = "";

  getfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File c = File(result.files.single.path.toString());
      setState(() {
        file = c;
        name = result.names.toString();
      });
      Navigator.of(context).pop();
     await  uploadFile('file');
    }
  }
  getMp3() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      File c = File(result.files.single.path.toString());
      setState(() {
        file = c;
        name = result.names.toString();
        value = result.count.toString();
      });
      Navigator.of(context).pop();

   await  uploadFile('mp3');
    }
  }
  bool? _isConnected;



  uploadFile(String type) async {
    try {
      final _auth = FirebaseAuth.instance;
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      var currentUserId = user.uid;
      var peerId = widget.userId2;
      final response = await InternetAddress.lookup('www.google.com');
      try {
        if (response.isNotEmpty) {
        var imagefile = FirebaseStorage.instance.ref('ChatRoom').child(
            '/file ${widget.groupChatId}').child("/${widget.username}");
        UploadTask task = imagefile.putFile(file!);
        TaskSnapshot snapshot = await task;
        url = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('messages')
            .doc(widget.groupChatId)
            .collection(widget.groupChatId)
            .add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': null,
          'file': url,
          'createdAt': Timestamp.now(),
          'username': userData['username'],
          'imageUrl': null,
          'userId2': peerId,
          'userId1': currentUserId,
          'userImage': userData['image_url'],
          'isStats': userData['isStats'],
          'type': type,
        });

        await FirebaseFirestore.instance
            .collection('last_message')
            .doc(user.uid)
            .collection(currentUserId).doc(widget.userId2)
            .set({
          'text': url,
          'timeSend': Timestamp.now(),
          'username': userData['username'],
          'userId2': peerId,
          'userId1': currentUserId,
          'userImage': userData['image_url'],
          'isStats': userData['isStats'],
          'type': type,});

        setState(() async{

          await FirebaseFirestore.instance
              .collection('last_message')
              .doc(currentUserId)
              .collection('${currentUserId}-${widget.userId2}').doc('${currentUserId}-${widget.userId2}')
              .update({
            'text':url,
            'type':type,
            'timeSend':Timestamp.now()
          });
        });





        if (url != null && file != null) {
          await Fluttertoast.showToast(
            msg: "Done Uploaded",
            textColor: Colors.red,
          );
        } else {
          await Fluttertoast.showToast(
            msg: "Something went wrong",
            textColor: Colors.red,
          );
        }
      }
    } on Exception catch (e) {
      await Fluttertoast.showToast(
        msg: e.toString(),
        textColor: Colors.red,
      );
    }}on SocketException catch (err) {
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.20,
      width: MediaQuery.of(context).size.width,
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
                      getfile();
                    },
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.indigo,
                          child: Icon(
                            Icons.insert_drive_file,
                            // semanticLabel: "Help",
                            size: 29,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Document',
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
                          await _picker.pickImage(source: ImageSource.camera);
                      if (pickedImageFile != null) {
                        setState(() {
                          _pickedImage = File(pickedImageFile.path);
                          Navigator.of(context).pop();

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatWithImageScreen(
                                  _pickedImage!,
                                  userData['username'],
                                  widget.groupChatId,
                                  widget.userId2)));
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
                              builder: (context) => ChatWithImageScreen(
                                  _pickedImage!,
                                  userData['username'],
                                  widget.groupChatId,
                                  widget.userId2)));

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
                  SizedBox(
                    width: 30,
                  ),
                  InkWell(
                    onTap: () async {
                      await getMp3();

                    },
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.orange,
                          child: Icon(
                            Icons.headset,
                            // semanticLabel: "Help",
                            size: 29,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Audio',
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
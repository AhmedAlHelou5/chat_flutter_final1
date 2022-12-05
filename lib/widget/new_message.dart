import 'dart:io';
import 'dart:math';
import 'package:chat_flutter_final/widget/bottom_sheet_attach_file.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';

class NewMessage extends StatefulWidget {
  final String username;
  final String image;
  final String userId2;
  final String groupChatId;
  final bool isStats;

  const NewMessage(
      this.username, this.image, this.userId2, this.groupChatId, this.isStats,
      {Key? key})
      : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> with WidgetsBindingObserver {
  var _isLoading = false;
  var emojiShowing = false;

  FocusNode focusNode = FocusNode();
  final _controller = TextEditingController();
  var _enteredMessage = '';
  final _auth = FirebaseAuth.instance;
  late User signedInUser;

  // void SetLastMessage(bool me,String lastMessage) {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(_auth.currentUser!.uid)
  //       .update({
  //     'isMe': me,
  //     'lastMessage':lastMessage,
  //   });
  // }


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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    WidgetsBinding.instance.addObserver(this);
  }

  bool? _isConnected;

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
        setState(() {
          _isConnected = true;
          FirebaseFirestore.instance
              .collection('messages')
              .doc(widget.groupChatId)
              .collection(widget.groupChatId)
              .add({
            'text': _enteredMessage,
            'imageUrl': null,
            'file': null,
            'createdAt': Timestamp.now(),
            'username': userData['username'],
            'userId2': peerId,
            'userId1': currentUserId,
            'userImage': userData['image_url'],
            'isStats': userData['isStats'],
            'type': 'text',
          });
          // FirebaseFirestore.instance
          //     .collection('users')
          //     .doc(peerId)
          //     .update({
          // 'lastMessage':_enteredMessage,
          //   'timeSend':Timestamp.now()
          //
          // });

          FirebaseFirestore.instance
              .collection('last_message')
              .doc(user.uid)
              .collection(user.uid).doc(signedInUser.uid)
              .set({
            'text': _enteredMessage,
            'timeSend': Timestamp.now(),
            'username': userData['username'],
            'userId2': peerId,
            'userId1': currentUserId,
            'userImage': userData['image_url'],
            'isStats': userData['isStats'],
            'type': 'text',});





          _controller.clear();
          setState(() {
            _enteredMessage = '';
          });
        });
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
  void _sendMessageVoice(File file) async {
    String? url ;
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
        var imagefile = FirebaseStorage.instance.ref('ChatRoom').child(
            '/file ${widget.groupChatId}').child("/${widget.username}");
        UploadTask task = imagefile.putFile(file);
        TaskSnapshot snapshot = await task;
        url = await snapshot.ref.getDownloadURL();

        setState(() {
          _isConnected = true; });
        await  FirebaseFirestore.instance
              .collection('messages')
              .doc(widget.groupChatId)
              .collection(widget.groupChatId)
              .add({
            'text': null,
            'imageUrl': null,
            'file': url,
            'createdAt': Timestamp.now(),
            'username': userData['username'],
            'userId2': peerId,
            'userId1': currentUserId,
            'userImage': userData['image_url'],
            'isStats': userData['isStats'],
            'type': 'mp3',
          });


        await  FirebaseFirestore.instance
              .collection('last_message')
              .doc(user.uid)
              .collection(user.uid).doc(signedInUser.uid)
              .set({
            'text': url,
            'timeSend': Timestamp.now(),
            'username': userData['username'],
            'userId2': peerId,
            'userId1': currentUserId,
            'userImage': userData['image_url'],
            'isStats': userData['isStats'],
            'type': 'voice',});


          _controller.clear();
          setState(() {
            _enteredMessage = '';
          });

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
    return Column(
        mainAxisAlignment: MainAxisAlignment.end, children: [
      ConstrainedBox(
        constraints: BoxConstraints.loose(Size.fromWidth(double.maxFinite)),

        child: Container(

          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: TextField(
                      textDirection: TextDirection.ltr,
                      controller: _controller,
                      autocorrect: true,
                      enableSuggestions: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                          hintText: 'Send a message...',
                          hintStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                          prefixIcon: IconButton(
                              icon: Icon(
                                  emojiShowing
                                      ? Icons.emoji_emotions_outlined
                                      : Icons.emoji_emotions_outlined,
                                  color: emojiShowing
                                      ? Theme.of(context).primaryColor
                                      : Colors.pinkAccent[100]),
                              onPressed: () {
                                setState(() {
                                  emojiShowing = !emojiShowing;
                                });
                              }),
                          suffixIcon: IconButton(
                                color: Theme.of(context).primaryColor,
                                disabledColor: Colors.pinkAccent[100],
                                onPressed: () {
                                showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (builder) => BottomSheetAttachFile(
                                widget.groupChatId,
                                widget.username,
                                widget.image,
                                widget.userId2),
                                );
                                },
                                icon: const Icon(
                                Icons.attach_file_rounded,
                                ),
                                ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1),
                              borderRadius: BorderRadius.circular(30)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1),
                              borderRadius: BorderRadius.circular(30))),
                      onChanged: (val) {
                        if (val.length > 0 && val != '') {
                          setState(() {
                            _enteredMessage = val;
                          });
                        } else {
                          setState(() {
                            _enteredMessage = '';
                          });
                        }
                      }),
                ),
              ),
              if( _enteredMessage.trim().isEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                           margin: EdgeInsets.only(top: 15),
                           child: SocialMediaRecorder(
                            sendRequestFunction: (soundFile)async {
                              print("the current path is ${soundFile.path}");
                              _sendMessageVoice(soundFile);

                                setState(() async{

                                      var imagefile = FirebaseStorage.instance.ref('ChatRoom').child(
                                      '/file ${widget.groupChatId}').child("/${widget.username}");
                                      UploadTask task = imagefile.putFile(soundFile);
                                      TaskSnapshot snapshot = await task;
                                    String  url = await snapshot.ref.getDownloadURL();

                                  await FirebaseFirestore.instance
                                      .collection('last_message')
                                      .doc(signedInUser.uid)
                                      .collection(signedInUser.uid).doc(signedInUser.uid)
                                      .update({
                                    'text':url,
                                    'type':'voice',
                                    'timeSend':Timestamp.now()
                                  });
                                });


                            },

                             encode: AudioEncoderType.AAC,
                             recordIcon: Icon(Icons.mic_rounded,color: Colors.pink,),
                             cancelTextBackGroundColor: Colors.red,
                             backGroundColor:Colors.white,
                             counterTextStyle: TextStyle(color: Colors.pink),
                             recordIconBackGroundColor: Colors.white,
                             sendButtonIcon: Icon(Icons.send,color: Colors.white,textDirection: TextDirection.ltr),
                             recordIconWhenLockBackGroundColor: Colors.pink,





                       ),
                  ),
                ),

              // IconButton(
              //     color: Theme.of(context).primaryColor,
              // onPressed: ()=>VoiceMessage(),
              //     icon: Icon(
              //             Icons.mic_rounded,
              //           )),
              if( _enteredMessage.trim().isNotEmpty)
              IconButton(
                  color: Theme.of(context).primaryColor,
                  onPressed:  () {
                    _sendMessage();
                    setState(() async {
                     await FirebaseFirestore.instance
                          .collection('last_message')
                          .doc(signedInUser.uid)
                          .collection(signedInUser.uid).doc(signedInUser.uid)
                          .update({
                        'text':_enteredMessage,
                        'timeSend':Timestamp.now()
                      });
                    });
                    },
                  icon: Icon(
                    Icons.send,
                  )),
            ],
          ),
        ),
      ),
      Offstage(
        offstage: !emojiShowing,
        child: SizedBox(
            height: 280,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                if (emoji.emoji.isNotEmpty) {
                  setState(() {
                    _controller.text = _controller.text + emoji.emoji;
                  });
                } else if (emoji != null) {
                  setState(() {
                    _controller.text = emoji.emoji;
                  });
                }
              },
              textEditingController: _controller,
              config: Config(
                columns: 9,
                // Issue: https://github.com/flutter/flutter/issues/28894
                emojiSizeMax: 32 * (Platform.isIOS ? 1.40 : 1.0),
                verticalSpacing: 0,
                horizontalSpacing: 0,
                gridPadding: EdgeInsets.zero,
                bgColor: const Color(0xFFF2F2F2),
                indicatorColor: Colors.blue,
                iconColor: Colors.grey,
                iconColorSelected: Colors.blue,
                skinToneDialogBgColor: Colors.white,
                skinToneIndicatorColor: Colors.grey,
                buttonMode: ButtonMode.MATERIAL,
              ),
            )),
      ),
    ]);
  }


// Future<bool> onBackPress() {
//   if (emojiShowing) {
//     setState(() {
//       emojiShowing = false;
//     });
//   } else {
//     Navigator.pop(context);
//   }
//
//   return Future.value(false);
//
// }
}
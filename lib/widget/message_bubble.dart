import 'dart:ui';
import 'package:chat_flutter_final/widget/audio_player.dart';
import 'package:chat_flutter_final/widget/file.dart';
import 'package:chat_flutter_final/widget/text.dart';
import 'package:chat_flutter_final/widget/text_with_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MessageBubble extends StatefulWidget {
  MessageBubble({
    required this.message,
    required this.userName,
    required this.userImage,
    required this.imageUrl,
    required this.file,
    required this.type,
    required this.userId2,
    required this.userId1,
    required this.date,
    required this.id,
    required this.isMe,
    required this.isState,
    Key? key,
  });

  final String? message;
  final String userName;
  final String userImage;
  final String? imageUrl;
  final String? file;
  final String type;
  final String userId2;
  final String userId1;
  final Timestamp date;
  final String id;
  final bool isMe;
  final bool isState;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  var currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String groupChatId = "";

  @override
  Widget build(BuildContext context) {
    String peerId = widget.userId2;
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }
    return SwipeTo(
          child: Row(
            mainAxisAlignment: !widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment:CrossAxisAlignment.end,
            children: [
              Container(
                child: Stack(
                    children: [
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: widget.isMe
                          ? CircleAvatar(
                              radius: 15,
                              backgroundImage: NetworkImage(widget.userImage),
                            )
                          : Container()),
                  Container(
                      margin: EdgeInsets.only(top: 18, left: 35),
                      child: widget.isMe
                          ? CircleAvatar(
                              radius: 5,
                              backgroundColor: widget.isState
                                  ? Colors.green
                                  : Colors.green.withAlpha(0),
                            )
                          : Container()),
                ]),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment:!widget.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Column(
                        children: [
                           ConstrainedBox(
                        constraints: BoxConstraints.loose(Size.fromWidth(double.maxFinite)),

                           child:Container(
                             decoration: BoxDecoration(
                                color: widget.isMe
                                    ? Colors.grey[300]
                                    : Theme.of(context).accentColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: widget.isMe
                                      ? const Radius.circular(0)
                                      : const Radius.circular(20),
                                  bottomRight: !widget.isMe
                                      ? const Radius.circular(0)
                                      : const Radius.circular(20),
                                )),
                            padding:
                                EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                            child: Column(

                              crossAxisAlignment:!widget.isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (widget.type == 'mp3')
                                  AudioPlayers(widget.file!, widget.isMe),
                                if (widget.type == 'voice')
                                  AudioPlayers(widget.file!, widget.isMe),
                                if (widget.type == 'file')
                                  FileMessage(widget.file!, widget.isMe),
                                if (widget.type == 'text')
                                  TextMessage(widget.message!, widget.isMe),
                                if (widget.type == 'text and image')
                                  TextWithImage(widget.imageUrl!, widget.message!,
                                      widget.isMe),

                                      Container(
                                        margin: widget.isMe
                                            ? EdgeInsets.only( top: 2)
                                            : EdgeInsets.only( top: 2),
                                        child: Text(
                                          DateFormat("h:mm a")
                                              .format(widget.date.toDate()),
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 10),
                                          textAlign: widget.isMe
                                              ? TextAlign.start
                                              : TextAlign.end,
                                        ),
                                      )

                              ],
                            ),
                          ),)
                      ]),

                  ],
                ),
              ),
            ],

    ),
            onRightSwipe: () async {

             // await FirebaseFirestore.instance
             //      .collection('messages')
             //      .doc(groupChatId).collection(groupChatId).doc(widget.message)
             //      .update({
             //    'delete': true,
             //  });

              // await FirebaseFirestore.instance
              //     .collection('messages')
              //     .doc(groupChatId).collection(groupChatId).doc(groupChatId)
              //     .update({
              //   'delete': true,
              // });

              // AlertDialog(
              //   title: Text("Success"),
              //   actions: [
              //     (onPressed: (){
              //     }, child: Text("Back")),
              //     DialogAction(onPressed: (){
              //     }, child: Text("Next")),
              //   ],
              //   content: Text("Saved successfully"),
              // )


             PanaraConfirmDialog.show(
               context,
               color: Colors.pink,
               title: "Warning",
               message: "Do you want to delete the message?",
               confirmButtonText: "Confirm",
               cancelButtonText: "Cancel",
               onTapCancel: () {
                 Navigator.pop(context);
               },
               onTapConfirm: ()async {
                 final deleteMessage= await FirebaseFirestore.instance
                     .collection('messages')
                     .doc(groupChatId).collection(groupChatId).doc(widget.id)
                     .update({
                   'delete': true,
                 });
                 Navigator.pop(context);

               },
               panaraDialogType: PanaraDialogType.warning,
               barrierDismissible: false, // optional parameter (default is true)
             );


             // await FirebaseFirestore.instance
             //     .collection('messages')
             //     .doc(groupChatId).collection(groupChatId).doc(widget.id)
             //     .update({
             //   'delete': true,
             // });



            },
          onLeftSwipe: ()async{
            // await FirebaseFirestore.instance
            //     .collection('messages')
            //     .doc(groupChatId).collection(groupChatId).doc()
            //     .update({
            //   'delete': true,
            // });

          },
          iconOnRightSwipe: Icons.delete_forever,
           iconColor: Colors.pink,
        );
  }



}
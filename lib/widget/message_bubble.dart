import 'dart:async';
import 'dart:ui';
import 'package:chat_flutter_final/res/assets_res.dart';
import 'package:chat_flutter_final/widget/audio_player.dart';
import 'package:chat_flutter_final/widget/deleted_message.dart';
import 'package:chat_flutter_final/widget/file.dart';
import 'package:chat_flutter_final/widget/text.dart';
import 'package:chat_flutter_final/widget/text_with_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_feed_reaction/flutter_feed_reaction.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    required this.isDelete,
    required this.isRead,
    required this.isState,
    Key? key, required this.reaction,
  });

  final String? message;
  final bool? reaction;
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
  final bool isDelete;
  final bool isRead;
  final bool isState;


  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}



class _MessageBubbleState extends State<MessageBubble> {
  var currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String groupChatId = "";

  // Widget _buildName({String? imageAsset, String? name}) {
  //   return
  //     // InkWell(
  //     // onTap: () {
  //     //   FirebaseFirestore.instance
  //     //       .collection('messages')
  //     //       .doc(groupChatId)
  //     //       .collection(groupChatId)
  //     //       .doc(widget.id)
  //     //       .update({
  //     //     'reaction': name!,
  //     //   });
  //     //   Navigator.of(context).pop();
  //     //
  //     //   print('reaction $groupChatId');
  //     //  print('reaction $name');
  //     // },
  //
  //     GestureDetector(
  //       onTap: (){
  //     FirebaseFirestore.instance
  //         .collection('messages')
  //         .doc(groupChatId)
  //         .collection(groupChatId)
  //         .doc(widget.id)
  //         .update({
  //       'reaction': name,
  //     });
  //     Navigator.of(context).pop();
  //
  //     print('reaction $groupChatId');
  //     print('reaction $name');
  //
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
  //         child: SingleChildScrollView(
  //           scrollDirection: Axis.vertical,
  //           child: Column(
  //             children:[
  //               CircleAvatar(
  //                 backgroundImage: AssetImage(imageAsset!),
  //                 backgroundColor: Theme.of(context).disabledColor,
  //                 radius: 13,
  //               ),
  //               Text(name!),
  //
  //             ],
  //
  //           ),
  //         ),
  //
  //   ),
  //     );
  // }
  @override
  Widget build(BuildContext context) {
    String peerId = widget.userId2;
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }




    if(currentUserId==widget.userId1){
      FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId).collection(groupChatId).doc(widget.id)
        .update({
      'isRead': true,
    });}
    return SwipeTo(
        child: Row(
          mainAxisAlignment:
              !widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            Container(
              child: Stack(children: [
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
              child: Row(
                mainAxisAlignment: !widget.isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [

                  Column(
                    crossAxisAlignment: !widget.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Column(children: [
                        ConstrainedBox(
                          constraints:
                              BoxConstraints.loose(Size.fromWidth(double.infinity)),
                          child: Container(
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
                            child: widget.isDelete? DeletedMessage('this message was deleted', widget.isMe):Column(
                              crossAxisAlignment: !widget.isMe
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
                                  TextWithImage(
                                      widget.imageUrl!, widget.message!, widget.isMe),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    widget.isRead == false
                                        ? SvgPicture.asset(
                                            'assets/images/check.svg',
                                            width: 20,
                                            height: 20,
                                            color: Colors.grey,
                                          )
                                        : SvgPicture.asset(
                                            'assets/images/check.svg',
                                            width: 20,
                                            height: 20,
                                            color: Colors.pink,
                                          ),
                                    Container(
                                      margin: widget.isMe
                                          ? EdgeInsets.only(top: 2)
                                          : EdgeInsets.only(top: 2),
                                      child: Text(
                                        DateFormat("h:mm a")
                                            .format(widget.date.toDate()),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                        textAlign: widget.isMe
                                            ? TextAlign.start
                                            : TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                      ]),
                    ],
                  ),
                  // if(widget.isDelete == false && currentUserId != widget.userId1)
                  //   GestureDetector(
                  //     child:widget.isMe ? GestureDetector(
                  //       onTap: (){
                  //         FirebaseFirestore.instance
                  //             .collection('messages')
                  //             .doc(groupChatId).collection(groupChatId).doc(widget.id)
                  //             .update({
                  //           'reaction': widget.reaction,
                  //         });
                  //       print( widget.reaction);
                  //       },
                  //       child: SvgPicture.asset(
                  //         AssetsRes.LIKE_SVG,
                  //         width: 20,
                  //         height: 20,
                  //         color: Theme.of(context).backgroundColor,
                  //       ),
                  //     ):
                  //       SvgPicture.asset(
                  //       AssetsRes.LIKE_SVG,
                  //         width: 20,
                  //         height: 20,
                  //         color: Theme.of(context).primaryColor,
                  //         ),
                  //
                  //   )

                 // !widget.isMe ?  SizedBox()
                 //      :GestureDetector(
                 //     onTap: (){
                 //       showDialog(
                 //         context: context,
                 //         builder: (context) {
                 //           return Dialog(
                 //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                 //             elevation: 16,
                 //             child: Container(
                 //               height: 60.0,
                 //               width: 360.0,
                 //               child: ListView(
                 //                 scrollDirection: Axis.horizontal,
                 //                 children: <Widget>[
                 //                   SizedBox(height: 20),
                 //                   // InkWell(
                 //                   //     onTap: () {
                 //                   //    FirebaseFirestore.instance
                 //                   //           .collection('messages')
                 //                   //           .doc(groupChatId)
                 //                   //           .collection(groupChatId)
                 //                   //           .doc(widget.id)
                 //                   //           .update({
                 //                   //         'reaction': 'like',
                 //                   //       });
                 //                   //       // Navigator.of(context).pop();
                 //                   //       print('reaction $groupChatId');
                 //                   //       print('reaction like');
                 //                   //     },
                 //                      _buildName(imageAsset:AssetsRes.LIKE, name: 'like'),
                 //                   // InkWell(
                 //                   //     onTap: () {
                 //                   //   FirebaseFirestore.instance
                 //                   //           .collection('messages')
                 //                   //           .doc(groupChatId)
                 //                   //           .collection(groupChatId)
                 //                   //           .doc(widget.id)
                 //                   //           .set({
                 //                   //         'reaction': 'sad',
                 //                   //       });
                 //                   //       Navigator.of(context).pop();
                 //                   //
                 //                   //       print('reaction $groupChatId');
                 //                   //       print('reaction sad');
                 //                   //     },
                 //                   //     child:
                 //                       _buildName(imageAsset: AssetsRes.SAD, name: 'sad'),
                 //                   // InkWell(
                 //                   //     onTap: (){
                 //                   //       setState(() {
                 //                   //         FirebaseFirestore.instance
                 //                   //             .collection('messages')
                 //                   //             .doc('${widget.userId2}-${widget.userId1}')
                 //                   //             .collection('${widget.userId2}-${widget.userId1}')
                 //                   //             .doc(widget.id)
                 //                   //             .set({
                 //                   //           'reaction': 'care',
                 //                   //         });
                 //                   //       });
                 //                   //
                 //                   //       print('reaction $groupChatId');
                 //                   //       print('reaction care');
                 //                   //      Navigator.of(context).pop();
                 //                   //
                 //                   //     },
                 //                   //     child:
                 //                       _buildName(imageAsset: AssetsRes.CARE, name: 'care'),
                 //                   // InkWell(
                 //                   //     onTap: () {
                 //                   //       setState(()  {
                 //                   //         FirebaseFirestore.instance
                 //                   //             .collection('messages')
                 //                   //             .doc(groupChatId)
                 //                   //             .collection(groupChatId)
                 //                   //             .doc(widget.id)
                 //                   //             .update({
                 //                   //           'reaction': 'heart',
                 //                   //         });
                 //                   //       });
                 //                   //
                 //                   //       // final heart =  FirebaseFirestore.instance
                 //                   //       //     .collection('messages')
                 //                   //       //     .doc(groupChatId)
                 //                   //       //     .collection(groupChatId)
                 //                   //       //     .doc(widget.id)
                 //                   //       //     .set({
                 //                   //       //   'reaction': 'heart',
                 //                   //       // });
                 //                   //       Navigator.of(context).pop();
                 //                   //
                 //                   //       print('reaction $groupChatId');
                 //                   //       print('reaction heart');
                 //                   //     }, child:
                 //                   _buildName(imageAsset: AssetsRes.HEART, name: 'heart'),
                 //                   // InkWell(
                 //                   //     onTap: () {
                 //                   //       final angry =  FirebaseFirestore.instance
                 //                   //           .collection('messages')
                 //                   //           .doc(groupChatId)
                 //                   //           .collection(groupChatId)
                 //                   //           .doc(widget.id)
                 //                   //           .set({
                 //                   //         'reaction': 'angry',
                 //                   //       });
                 //                   //       Navigator.of(context).pop();
                 //                   //
                 //                   //       print('reaction $groupChatId');
                 //                   //       print('reaction angry');
                 //                   //     },
                 //                   //     child:
                 //                       _buildName(imageAsset: AssetsRes.ANGRY, name: 'angry'),
                 //                   // InkWell(
                 //                   //     onTap: () {
                 //                   //       final lol =   FirebaseFirestore.instance
                 //                   //           .collection('messages')
                 //                   //           .doc(groupChatId)
                 //                   //           .collection(groupChatId)
                 //                   //           .doc(widget.id)
                 //                   //           .set({
                 //                   //         'reaction': 'lol',
                 //                   //       });
                 //                   //       Navigator.of(context).pop();
                 //                   //
                 //                   //       print('reaction $groupChatId');
                 //                   //       print('reaction lol');
                 //                   //     },
                 //                   //     child:
                 //                       _buildName(imageAsset: AssetsRes.LOL, name: 'lol'),
                 //
                 //                   SizedBox(height: 20),
                 //
                 //                 ],
                 //               ),
                 //             ),
                 //           );
                 //         },
                 //       );
                 //       },
                 //     child:
                 //      Icon(.,color: Colors.pink,size: 15,)),




                ],
              ),
            ),
          ],
        ),

      onRightSwipe: ()  {
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

          onTapConfirm: ()  {
              FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .doc(widget.id)
                  .update({
                'delete': true,
              });
              print(' delete $groupChatId');

               FirebaseFirestore.instance
                  .collection('last_message')
                  .doc(groupChatId)
                  .update({
                'text':'this message was deleted',
                'timeSend':Timestamp.now(),
                'isRead':false
              });
            Navigator.pop(context);
          },
          panaraDialogType: PanaraDialogType.warning,
          barrierDismissible: false, // optional parameter (default is true)
        );
      },
      onLeftSwipe: () async {
      },
      iconOnRightSwipe: Icons.delete_forever,
      iconColor: Colors.pink,
       );
  }


}



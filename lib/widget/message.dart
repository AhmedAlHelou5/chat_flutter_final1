import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class Message extends StatefulWidget {
  Message(this.isStats,this.groupChatId,this.userId2,this.isMe,{Key? key});

  final bool isStats;
  final String groupChatId;
  final String userId2;

  bool isMe;

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  final currentUser = FirebaseAuth.instance.currentUser!;
    final _scrollController=ScrollController();
  var currentUserId=FirebaseAuth.instance.currentUser!.uid ;
  @override
  Widget build(BuildContext context) {

    final message=
    FirebaseFirestore.instance
        .collection('messages')
        .doc(widget.groupChatId)
        .collection(widget.groupChatId)
        .orderBy('createdAt', descending: true).limit(50)
        .snapshots();
    return  StreamBuilder(
      stream : message,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {

          return Center(
            child: CircularProgressIndicator(),

          );

        }
        List<DocumentSnapshot> documents = snapshot.data!.docs;
        final  chat = [];


        documents.forEach((element) {
          chat.add(
            MessageBubble(
            message: element['text'] ??'',
            type: element['type'],
            userName:element['username'],
            userImage: element['userImage'],
            imageUrl: element['imageUrl']??'',
            file: element['file']??'' ,
            userId2: element['userId2'],
            userId1: element['userId1'],
            date: element['createdAt'],
            isMe: element['userId2'] == widget.userId2 ? widget.isMe=false : widget.isMe=true,
            isState: widget.isStats,
            key: ValueKey(currentUser.uid ),
            ) );
        });



        return ListView.builder(
          reverse: true,
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: snapshot.data!.docs.length,

          itemBuilder: (ctx, index) {
              return chat[index];

          }
        );


      }
      );}
}

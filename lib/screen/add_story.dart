import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_flutter_final/widget/bottom_sheet_for_story_pick.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddStory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_AddStoryState();
}

class _AddStoryState extends State<AddStory>  with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final userData=FirebaseFirestore.instance.collection('users').snapshots();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading:  IconButton(
          icon: Icon(Icons.keyboard_backspace_outlined),
          color: Colors.white, onPressed: () {  Navigator.of(context).pop();},

        ),
      ),
      body:  InkWell(
        onTap: (){
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (builder) => BottomSheetForStoryPick(
            ),
          );
        },
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Container(
                width: 200,
                height: 200,
                child: Image.asset('assets/images/a.png',),
              ),

              Container(
                child: TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (builder) => BottomSheetForStoryPick(
                              ),
                          );
                        },
                        child: Text('Add Story', style: TextStyle(color: Colors.pink,fontSize: 20,)),
                      ),
              ),
              ],
            ),
          ),
      ),
    );
  }
}

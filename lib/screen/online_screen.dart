import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'chat_screen.dart';

class OnlineScreen extends StatefulWidget {
  @override
  State<OnlineScreen> createState() => _OnlineScreenState();
}
class _OnlineScreenState extends State<OnlineScreen>
    with WidgetsBindingObserver {
  final _auth = FirebaseAuth.instance;
  late User signedInUser;

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void SetStatus(bool status) {
    FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'isStats': status,
    });
  }

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

  bool? _isConnected;

  void _checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty) {
        setState(() {
          _isConnected = true;
          SetStatus(true);
        });
      }
    } on SocketException catch (err) {
      setState(() {
        _isConnected = false;
        SetStatus(false);
      });
      if (kDebugMode) {
        print(err);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkInternetConnection();
    getCurrentUser();
    WidgetsBinding.instance.addObserver(this);
    SetStatus(true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isConnected == true) {
      SetStatus(true);
    } else {
      SetStatus(false);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SetStatus(false);
    super.dispose();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    SetStatus(false);

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          //wrap with PreferredSize
          preferredSize: Size.fromHeight(55),
          child: AppBar(
              elevation: 3,
              title: Text('Online'),
              centerTitle: true,

              actions: [
                Container(
                  margin: EdgeInsets.only(right: 15),
                  child: DropdownButton(
                    underline: Container(),
                    icon: Icon(Icons.menu,
                        color: Theme
                            .of(context)
                            .primaryIconTheme
                            .color,
                        size: 27),
                    items: [
                      DropdownMenuItem(
                        value: 'logout',
                        child: Row(
                          children: const [
                            Icon(
                              Icons.exit_to_app,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text('Logout'),
                          ],
                        ),
                      )
                    ],
                    onChanged: (itemIdentifier) async {
                      if (itemIdentifier == 'logout') {
                        SetStatus(false);
                        await FirebaseAuth.instance.signOut();
                      }
                    },
                  ),
                ),
              ]),
        ),

      body: Column(
      children:[
        Expanded(
          flex: 5,
          child: Card(
            color: Theme.of(context).accentColor,
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10, left: 20),
                  child: Text(
                    'Online',
                    style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                Card(
                  elevation: 5,
                  child: Container(
                      height: MediaQuery.of(context).size.height * 0.75,
                      margin: EdgeInsets.only(
                          top: 15, right: 10, left: 10),
                      width: double.infinity,
                      child: StreamBuilder(
                          stream:  FirebaseFirestore.instance
                              .collection('users')
                              .where('isStats',isEqualTo: true)
                              .snapshots(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final documents = snapshot.data!.docs;
                            var index =0;
                            print('messages ${documents.length}');
                            return  documents[index]['isStats']==true? ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: documents.length,
                                itemBuilder: (ctx, index) {
                                  var isStats = documents[index]['isStats'];
                                  var userId = documents[index]['userId'];

                                  return   Column(
                                    children: [
                                      Container(
                                        child: ListTile(
                                          contentPadding: EdgeInsets
                                              .all(5),
                                          leading: Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundImage:
                                                NetworkImage(
                                                    documents[index]
                                                    ['image_url']),
                                              ),
                                              Positioned(
                                                  top: 35,
                                                  left: 33,
                                                  child: CircleAvatar(
                                                    radius: 7,
                                                    backgroundColor:
                                                    documents[index]
                                                    ['isStats']
                                                        ? Colors.green
                                                        : Colors.green
                                                        .withAlpha(
                                                        0),
                                                  )),
                                            ],
                                          ),
                                          title: Text(
                                            documents[index]['username'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight:
                                                FontWeight.normal,
                                                fontSize: 15),
                                          ),
                                          // subtitle: Column(
                                          //   children: [
                                          //     if (documents[index]['type'] == 'Image')
                                          //       Row(mainAxisAlignment:MainAxisAlignment.start,children: [Text('Photo',style: TextStyle(color: Colors.black87,fontSize: 13)),Icon(Icons.photo,size: 15)],),
                                          //     if (documents[index]['type'] == 'mp3')
                                          //       Row(mainAxisAlignment:MainAxisAlignment.start,children: [Text('File Music',style: TextStyle(color: Colors.black87,fontSize: 13)),Icon(Icons.music_video_rounded,size: 15)],),
                                          //     if (documents[index]['type'] == 'file')
                                          //       Row(mainAxisAlignment:MainAxisAlignment.start,children: [Text('File Pdf',style: TextStyle(color: Colors.black87,fontSize: 13)),Icon(Icons.picture_as_pdf,size: 15,)],),
                                          //     if (documents[index]['type'] == 'voice')
                                          //       Row(mainAxisAlignment:MainAxisAlignment.start,children: [Text('Voice',style: TextStyle(color: Colors.black87,fontSize: 13)),Icon(Icons.keyboard_voice_sharp,size: 15,)],),
                                          //     if (documents[index]['type'] == 'text and image')
                                          //       Row(mainAxisAlignment:MainAxisAlignment.start,children: [ Text(documents[index]['text']=="" ? 'Photo':documents[index]['text']),Icon(Icons.photo,size: 15,)],),
                                          //     if (documents[index]['type'] == 'text')
                                          //       Row(mainAxisAlignment:MainAxisAlignment.start,
                                          //         children: [
                                          //           Text(documents[index]['text']??'Send First Message',style: TextStyle(color: Colors.black87,fontSize: 13),),
                                          //         ],
                                          //       )
                                          //   ],
                                          // ),


                                          // trailing: Text(
                                          //   DateFormat("h:mm a").format(
                                          //       documents[index]['timeSend']
                                          //           .toDate()),
                                          //   style: TextStyle(
                                          //       color: Colors.black87,
                                          //       fontSize: 10),
                                          // ),
                                          onTap: () async {
                                            await Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatScreen(
                                                      documents[index]
                                                      ['username'],
                                                      documents[index]
                                                      ['image_url'],
                                                      documents[index]
                                                      ['userId'],
                                                      currentUserId,
                                                      documents[index]
                                                      ['isStats']),
                                            ));
                                          },
                                        ), //                           <-- Divider
                                      )
                                      //     :Container(
                                      //   child:Image(image: AssetImage('assets/images/b.jpg')),
                                      // ),
                                      // Divider(),

                                      // Divider(height: 0.02,color: Colors.grey),
                                  ],
                                  );
                                })  :Container(
                                  child:Image(image: AssetImage('assets/images/b.jpg')),
                                )
                            ;
                          })),
                ),
              ],
            ),
          ),
        ),

      ])
    );
  }
}
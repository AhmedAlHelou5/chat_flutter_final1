import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screen/chat_screen.dart';

class HomeScreenWidget extends StatefulWidget {
  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget>
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
    // final lastMessage=
    // FirebaseFirestore.instance
    //     .collection('messages')
    //     .doc(widget.groupChatId)
    //     .collection(widget.groupChatId)
    //     .orderBy('createdAt', descending: true).limit(1)
    //     .snapshots();
    //
    
    return Scaffold(
        appBar: PreferredSize(
          //wrap with PreferredSize
          preferredSize: Size.fromHeight(55),
          child: AppBar(
              elevation: 4,
              title: Text('Messages'),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.exit_to_app), onPressed: () {

              },
              ),
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 15),
                  child: DropdownButton(
                    underline: Container(),
                    icon: Icon(Icons.search_rounded,
                        color: Theme.of(context).primaryIconTheme.color,
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

                        // Navigator.push(s
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) =>  AuthScreen()),
                        // );
                      }
                    },
                  ),
                ),
              ]),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Expanded(
              flex: 1,
              child: Card(
                elevation: 3,
                shape:BeveledRectangleBorder(side:BorderSide(width: 1,color: Colors.grey) ) ,
                child: Container(
                  height: 90,
                    margin: EdgeInsets.only(top: 15,right: 10,left: 10),

                    child: StreamBuilder(
                        stream:
                            FirebaseFirestore.instance.collection('users').snapshots(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final documents = snapshot.data!.docs;
                          print('users ${documents.length}');
                          return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: documents.length,
                              itemBuilder: (ctx, index) {
                                var isStats = documents[index]['isStats'];
                                return Container(
                                  width: 90,
                                    height: 100,
                                    child: ListTile(
                                        leading: Column(
                                          children: [
                                          //  Container(
                                          //    child: ClipRRect(
                                          //      borderRadius: BorderRadius.circular(20.0),
                                          //      child: CachedNetworkImage(
                                          //       imageUrl: documents[index]['image_url'],
                                          //        height: 70.0,
                                          //        width: 70.0,
                                          //        fit: BoxFit.cover,
                                          // ),
                                          //    ),
                                          //  ),
                                          //   CachedNetworkImage(
                                          //   imageUrl: documents[index]['image_url'],
                                          //   fit: BoxFit.fitHeight,
                                          //   imageBuilder: (context, imageProvider) => Container(
                                          //     width: 70.0,
                                          //     height: 70.0,
                                          //     decoration: BoxDecoration(
                                          //       shape: BoxShape.circle,
                                          //       image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                          //     ),
                                          //   ),),

                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage: NetworkImage(documents[index]['image_url']),
                                        ),

                                              Container(
                                                margin: EdgeInsets.only(top: 5),
                                                child: Text(
                                                  documents[index]['username'],
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.normal,fontSize: 13),
                                                ),
                                              ),

                                   ] ),
                                        onTap: () async {
                                          await Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                                documents[index]['username'],
                                                documents[index]['image_url'],
                                                documents[index]['userId'],
                                                currentUserId,
                                                documents[index]['isStats']),
                                          ));
                                        }));
                              });
                        })),
              ),
            ),
            // Expanded(
            //   flex: 6,
            //   child: Card(
            //     elevation: 3,
            //     shape:BeveledRectangleBorder(side:BorderSide(width: 1,color: Colors.grey) ) ,
            //     child: Container(
            //         margin: EdgeInsets.only(top: 15,right: 10,left: 10),
            //         width: double.infinity,
            //
            //         child: StreamBuilder(
            //             stream:
            //             // FirebaseFirestore.instance
            //             //     .collection('messages')
            //             //     .doc(widget.groupChatId)
            //             //     .collection(widget.groupChatId)
            //             //     .orderBy('createdAt', descending: true).limit(1)
            //             //     .snapshots(),
            //             builder: (context, AsyncSnapshot snapshot) {
            //               if (snapshot.connectionState == ConnectionState.waiting) {
            //                 return Center(
            //                   child: CircularProgressIndicator(),
            //                 );
            //               }
            //               final documents = snapshot.data!.docs;
            //               print('messages ${documents.length}');
            //               return ListView.builder(
            //                   scrollDirection: Axis.vertical,
            //                   itemCount: documents.length,
            //                   itemBuilder: (ctx, index) {
            //                     // var isStats = documents[index]['isStats'];
            //
            //                     return Column(
            //                       children: [
            //                         Container(
            //                           margin: EdgeInsets.only(top: 7),
            //                             child: ListTile(
            //
            //                                leading: Stack(
            //                                  children: [
            //                                    CircleAvatar(
            //                                      radius: 25,
            //                                      backgroundImage: NetworkImage(documents[index]['image_url']),
            //                                    ),
            //                                    // Positioned(
            //                                    //     top: 35,
            //                                    //     left: 33,
            //                                    //     child: CircleAvatar(
            //                                    //       radius: 7,
            //                                    //       backgroundColor:
            //                                    //       isStats ? Colors.green : Colors.green.withAlpha(0),
            //                                    //     )
            //                                    // ),
            //
            //                                                         ],),
            //                                   title: Text(
            //                                           documents[index]['username'],
            //                                           style: TextStyle(
            //                                               color: Colors.black,
            //                                               fontWeight: FontWeight.normal,fontSize: 15),
            //                                         ),
            //
            //                                   subtitle:
            //
            //
            //                                   Text(
            //                                      documents[index]['text'],
            //                                     style: TextStyle(
            //                                         color: Colors.black,
            //                                         wordSpacing: 1.5,
            //                                         letterSpacing: 0.2,
            //                                         fontWeight: FontWeight.normal,fontSize: 13),
            //                                   ),
            //
            //                                 //
            //                                       // Container(
            //                                       //   margin: EdgeInsets.only(top: 5),
            //                                       //   child: Text(
            //                                       //     documents[index]['username'],
            //                                       //     style: TextStyle(
            //                                       //         color: Colors.black,
            //                                       //         fontWeight: FontWeight.normal,fontSize: 13),
            //                                       //   ),
            //                                       // ),
            //
            //
            //                                 onTap: () async {
            //                                   await Navigator.of(context)
            //                                       .push(MaterialPageRoute(
            //                                     builder: (context) => ChatScreen(
            //                                         documents[index]['username'],
            //                                         documents[index]['image_url'],
            //                                         documents[index]['userId'],
            //                                         currentUserId,
            //                                         documents[index]['isStats']),
            //                                   ));
            //                                 }),    //                           <-- Divider
            //                         ),
            //                         // Divider(height: 0.02,color: Colors.grey),
            //                       ],
            //                     );
            //
            //                   });
            //             })),
            //   ),
            // ),

          ],
        ));
  }
}

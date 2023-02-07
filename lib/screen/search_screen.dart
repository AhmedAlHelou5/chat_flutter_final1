// import 'dart:io';
//
// import 'package:chat_flutter_final/widget/new_message.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fsearch/fsearch.dart';
// import 'package:intl/intl.dart';
//
// import 'chat_screen.dart';
//
// class SearchScreen extends StatefulWidget {
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen>
//     with WidgetsBindingObserver {
//   final _auth = FirebaseAuth.instance;
//   late User signedInUser;
//
//   final currentUserId = FirebaseAuth.instance.currentUser!.uid;
//
//   void SetStatus(bool status) {
//     FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
//       'isStats': status,
//     });
//   }
//
//   void getCurrentUser() {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         signedInUser = user;
//       }
//     } catch (e) {
//       print("Error getting current user: $e ");
//     }
//   }
//
//   bool? _isConnected;
//
//   void _checkInternetConnection() async {
//     try {
//       final response = await InternetAddress.lookup('www.google.com');
//       if (response.isNotEmpty) {
//         setState(() {
//           _isConnected = true;
//           SetStatus(true);
//         });
//       }
//     } on SocketException catch (err) {
//       setState(() {
//         _isConnected = false;
//         SetStatus(false);
//       });
//       if (kDebugMode) {
//         print(err);
//       }
//     }
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _checkInternetConnection();
//     getCurrentUser();
//     WidgetsBinding.instance.addObserver(this);
//     SetStatus(true);
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // TODO: implement didChangeAppLifecycleState
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.resumed && _isConnected == true) {
//       SetStatus(true);
//     } else {
//       SetStatus(false);
//     }
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     SetStatus(false);
//     super.dispose();
//   }
//
//   @override
//   void deactivate() {
//     // TODO: implement deactivate
//     SetStatus(false);
//
//     super.deactivate();
//   }
//
//   FocusNode focusNode = FocusNode();
//
//   // final _controller = FSearchController();
//   var _enteredMessage = '';
//   TextEditingController _controller = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final _usersStream = FirebaseFirestore.instance
//         .collection('users')
//         .where('username', isEqualTo: _enteredMessage.substring(0,_enteredMessage.length).toUpperCase())
//         .snapshots();
//
//     return Scaffold(
//         appBar: AppBar(
//         title:Center(child: Text('Searching...')),
//     ),
//     body: Column(
//       children: [
//         Container(
//           margin: EdgeInsets.only(top: 10,left: 10,right: 10),
//           child: TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               // prefixIcon: Icon(Icons.search_rounded,color: Colors.pink,size: 20,),
//               hintText: 'Search',
//                 prefixIcon: Icon(Icons.search_rounded,color: Colors.pink,size: 20,),
//                 hintStyle: TextStyle(color: Colors.pink),
//                 focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Theme.of(context).primaryColor,
//                         width: 1),
//                     borderRadius: BorderRadius.circular(30)),
//                 enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Theme.of(context).primaryColor,
//                         width: 1),
//                     borderRadius: BorderRadius.circular(30))),
//
//               onChanged: (val) {
//               setState(() {
//                     _enteredMessage = val;
//                   });
//
//               },
//           ),
//         ),
//     Container(
//       margin: EdgeInsets.only(top: 10),
//     child: Card(
//     elevation: 1,
//     shape: BeveledRectangleBorder(
//     side: BorderSide(width: 1, color: Colors.grey)),
//     child: Container(
//     width: MediaQuery.of(context).size.width * 0.93,
//     height: MediaQuery.of(context).size.height * 0.72,
//
//     child: StreamBuilder(
//         stream: _usersStream,
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Text("something is wrong");
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           final documents = snapshot.data!.docs;
//
//
//           return  ListView.builder(
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (ctx, index) {
//                   return Container(
//                     margin: EdgeInsets.only(top: 10),
//                     child: ListTile(
//                         leading: Stack(
//                           children: [
//                             CircleAvatar(
//                               radius: 25,
//                               backgroundImage:
//                               NetworkImage(
//                                   documents[
//                                   index]
//                                   [
//                                   'image_url']),
//                             ),
//                             Positioned(
//                                 top: 35,
//                                 left: 33,
//                                 child: CircleAvatar(
//                                   radius: 7,
//                                   backgroundColor: documents[
//                                   index]
//                                   [
//                                   'isStats']
//                                       ? Colors
//                                       .green
//                                       : Colors
//                                       .green
//                                       .withAlpha(
//                                       0),
//                                 )),
//                           ],
//                         ),
//                         title: Text(
//                           documents[index]
//                           ['username'],
//                           style: TextStyle(
//                               color: Colors
//                                   .black,
//                               fontWeight:
//                               FontWeight.bold,
//                               fontSize: 15),
//                         ),
//                         // subtitle: documents[index][
//                         // 'lastMessage'] !=
//                         //     null
//                         //     ? Container(
//                         //   child: documents[
//                         //   index]
//                         //   [
//                         //   'lastMessage'] !=
//                         //       null
//                         //       ? Text(
//                         //     documents[
//                         //     index]
//                         //     [
//                         //     'lastMessage'],
//                         //     style: TextStyle(
//                         //         color: Colors
//                         //             .black87,
//                         //         wordSpacing:
//                         //         1.5,
//                         //         letterSpacing:
//                         //         0.2,
//                         //         fontWeight:
//                         //         FontWeight
//                         //             .normal,
//                         //         fontSize:
//                         //         14),
//                         //   )
//                         //       : Text(
//                         //     'file 📁 ',
//                         //     style: TextStyle(
//                         //         color: Colors
//                         //             .black87,
//                         //         wordSpacing:
//                         //         1.5,
//                         //         letterSpacing:
//                         //         0.2,
//                         //         fontWeight:
//                         //         FontWeight
//                         //             .normal,
//                         //         fontSize:
//                         //         14),
//                         //   ),
//                         // )
//                         //     : Container(
//                         //     child: Text(
//                         //       'send a first message',
//                         //       style: TextStyle(
//                         //           color: Colors
//                         //               .black87,
//                         //           wordSpacing:
//                         //           1.5,
//                         //           letterSpacing:
//                         //           0.2,
//                         //           fontWeight:
//                         //           FontWeight
//                         //               .normal,
//                         //           fontSize: 14),
//                         //     )),
//                         //
//                         // trailing: documents[index]
//                         // ['timeSend'] !=
//                         //     null
//                         //     ? Container(
//                         //   child: Text(
//                         //     DateFormat(
//                         //         "h:mm a")
//                         //         .format(
//                         //         documents[
//                         //         index]
//                         //         [
//                         //         'timeSend']
//                         //             .toDate()),
//                         //     style: const TextStyle(
//                         //         color: Colors
//                         //             .black87,
//                         //         fontSize: 11),
//                         //   ),
//                         // )
//                         //     : Container(
//                         //   child: Text(
//                         //     DateFormat(
//                         //         "h:mm a")
//                         //         .format(DateTime
//                         //         .now()),
//                         //     style: const TextStyle(
//                         //         color: Colors
//                         //             .black87,
//                         //         fontSize: 11),
//                         //   ),
//                         // ),
//                         onTap: () async {
//                           await Navigator.of(
//                               context)
//                               .push(
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     ChatScreen(
//                                         documents[index]
//                                         ['username'],
//                                         documents[index]
//                                         [
//                                         'image_url'],
//                                         documents[index]
//                                         ['userId'],
//                                         currentUserId,
//                                       isState: documents[index]
//                                       ['isStats'],
//
//                                        ),
//                               ));
//
//
//                           // Divider(height: 0.02,color: Colors.grey),
//
//                         }),
//                   );
//                 });}
//     )) )
//     )
//    ] ) );
//                 }
//
//
//     }
//
// // @override
// // Widget build(BuildContext context) {
// //
// //   return Scaffold(
// //       appBar: PreferredSize(
// //         //wrap with PreferredSize
// //         preferredSize: Size.fromHeight(55),
// //         child: AppBar(
// //           elevation: 4,
// //           title: Text('Search'),
// //           centerTitle: true,
// //
// //         ),),
// //       body: Column(
// //         mainAxisAlignment: MainAxisAlignment.start,
// //
// //           children:[
// //             SizedBox(height: 10,),
// //             Container(
// //               child: FSearch(
// //                 controller: _controller,
// //                 margin:  EdgeInsets.only(right: 10,left: 10),
// //                 height: 40.0,
// //                 style: TextStyle(fontSize: 16.0, height: 1.0, color: Colors.pink),
// //
// //                 cornerStyle: FSearchCornerStyle.round,
// //                 strokeColor: Colors.pink,
// //                 strokeWidth: 1.5,
// //                 corner: FSearchCorner(
// //                     leftTopCorner: 15.0,
// //                     leftBottomCorner: 15.0,
// //                     rightTopCorner: 15.0,
// //                     rightBottomCorner: 15.0),
// //
// //
// //                 onSearch: (value) {
// //                   _enteredMessage=value;
// //
// //                 },
// //                 prefixes: [
// //                   SizedBox(width: 5,),
// //                   Icon(
// //                     Icons.search,
// //                     size: 25,
// //                     color: Colors.pink,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Expanded(
// //                     child: Container(
// //                         height: MediaQuery.of(context).size.height ,
// //                         margin: EdgeInsets.only(top: 15, right: 10, left: 10),
// //                         child: StreamBuilder(
// //                             stream: FirebaseFirestore.instance
// //                                 .collection('users').where(_enteredMessage,isEqualTo: 'username')
// //                                 .snapshots(),
// //                             builder: (context, AsyncSnapshot snapshot) {
// //                               if (snapshot.connectionState ==
// //                                   ConnectionState.waiting) {
// //                                 return Center(
// //                                   child: CircularProgressIndicator(),
// //                                 );
// //                               }
// //
// //                               final documents = snapshot.data!.docs;
// //                               print('messages ${documents.length}');
// //                               return ListView.builder(
// //                                   scrollDirection: Axis.vertical,
// //                                   itemCount: documents.length,
// //                                   itemBuilder: (ctx, index) {
// //                                     // var isStats = documents[index]['isStats'];
// //                                     return Column(
// //                                       children: [
// //                                         Container(
// //                                           child: currentUserId !=
// //                                               documents[index]['userId']
// //                                               ? ListTile(
// //                                               leading: Stack(
// //                                                 children: [
// //                                                   CircleAvatar(
// //                                                     radius: 25,
// //                                                     backgroundImage:
// //                                                     NetworkImage(
// //                                                         documents[
// //                                                         index]
// //                                                         [
// //                                                         'image_url']),
// //                                                   ),
// //                                                   Positioned(
// //                                                       top: 35,
// //                                                       left: 33,
// //                                                       child: CircleAvatar(
// //                                                         radius: 7,
// //                                                         backgroundColor: documents[
// //                                                         index]
// //                                                         [
// //                                                         'isStats']
// //                                                             ? Colors
// //                                                             .green
// //                                                             : Colors
// //                                                             .green
// //                                                             .withAlpha(
// //                                                             0),
// //                                                       )),
// //                                                 ],
// //                                               ),
// //                                               title: Text(
// //                                                 documents[index]
// //                                                 ['username'],
// //                                                 style: TextStyle(
// //                                                     color: Colors
// //                                                         .black,
// //                                                     fontWeight:
// //                                                     FontWeight.bold,
// //                                                     fontSize: 15),
// //                                               ),
// //                                               subtitle: documents[index][
// //                                               'lastMessage'] !=
// //                                                   null
// //                                                   ? Container(
// //                                                 child: documents[
// //                                                 index]
// //                                                 [
// //                                                 'lastMessage'] !=
// //                                                     null
// //                                                     ? Text(
// //                                                   documents[
// //                                                   index]
// //                                                   [
// //                                                   'lastMessage'],
// //                                                   style: TextStyle(
// //                                                       color: Colors
// //                                                           .black87,
// //                                                       wordSpacing:
// //                                                       1.5,
// //                                                       letterSpacing:
// //                                                       0.2,
// //                                                       fontWeight:
// //                                                       FontWeight
// //                                                           .normal,
// //                                                       fontSize:
// //                                                       14),
// //                                                 )
// //                                                     : Text(
// //                                                   'file 📁 ',
// //                                                   style: TextStyle(
// //                                                       color: Colors
// //                                                           .black87,
// //                                                       wordSpacing:
// //                                                       1.5,
// //                                                       letterSpacing:
// //                                                       0.2,
// //                                                       fontWeight:
// //                                                       FontWeight
// //                                                           .normal,
// //                                                       fontSize:
// //                                                       14),
// //                                                 ),
// //                                               )
// //                                                   : Container(
// //                                                   child: Text(
// //                                                     'send a first message',
// //                                                     style: TextStyle(
// //                                                         color: Colors
// //                                                             .black87,
// //                                                         wordSpacing:
// //                                                         1.5,
// //                                                         letterSpacing:
// //                                                         0.2,
// //                                                         fontWeight:
// //                                                         FontWeight
// //                                                             .normal,
// //                                                         fontSize: 14),
// //                                                   )),
// //
// //                                               trailing: documents[index]
// //                                               ['timeSend'] !=
// //                                                   null
// //                                                   ? Container(
// //                                                 child: Text(
// //                                                   DateFormat(
// //                                                       "h:mm a")
// //                                                       .format(
// //                                                       documents[
// //                                                       index]
// //                                                       [
// //                                                       'timeSend']
// //                                                           .toDate()),
// //                                                   style: const TextStyle(
// //                                                       color: Colors
// //                                                           .black87,
// //                                                       fontSize: 11),
// //                                                 ),
// //                                               )
// //                                                   : Container(
// //                                                 child: Text(
// //                                                   DateFormat(
// //                                                       "h:mm a")
// //                                                       .format(DateTime
// //                                                       .now()),
// //                                                   style: const TextStyle(
// //                                                       color: Colors
// //                                                           .black87,
// //                                                       fontSize: 11),
// //                                                 ),
// //                                               ),
// //                                               onTap: () async {
// //                                                 await Navigator.of(
// //                                                     context)
// //                                                     .push(
// //                                                     MaterialPageRoute(
// //                                                       builder: (
// //                                                           context) =>
// //                                                           ChatScreen(
// //                                                               documents[index]
// //                                                               [
// //                                                               'username'],
// //                                                               documents[index]
// //                                                               [
// //                                                               'image_url'],
// //                                                               documents[index]
// //                                                               ['userId'],
// //                                                               currentUserId,
// //                                                               documents[index]
// //                                                               [
// //                                                               'isStats']),
// //                                                     ));
// //                                               })
// //                                               : Container(), //                           <-- Divider
// //                                         ),
// //                                         // Divider(height: 0.02,color: Colors.grey),
// //                                       ],
// //                                     );
// //                                   });
// //                             } )))
// //
// //            ] )
// //   );
// // }
//

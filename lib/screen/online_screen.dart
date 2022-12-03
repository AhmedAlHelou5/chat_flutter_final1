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
    elevation: 4,
    title: Text('Online'),
    centerTitle: true,

    ),),
      body: Column(
      children:[
      Expanded(
        flex: 5,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.99,
          child: Card(
            elevation: 3,
            shape: BeveledRectangleBorder(
                side: BorderSide(width: 1, color: Colors.grey)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.only(left: 25, top: 15),
                    child: Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )),
                Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    margin: EdgeInsets.only(top: 15, right: 10, left: 10),
                    child:  StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users').where('isStats',isEqualTo: true)
                            .snapshots(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final documents = snapshot.data!.docs;



                          print('messages ${documents.length}');
                          return documents.length >1 ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: documents.length,
                              itemBuilder: (ctx, index) {
                                // var isStats = documents[index]['isStats'];
                                return Column(
                                  children: [
                                    Container(
                                      child: currentUserId !=
                                          documents[index]['userId']
                                          ? ListTile(
                                          leading: Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundImage:
                                                NetworkImage(
                                                    documents[
                                                    index]
                                                    [
                                                    'image_url']),
                                              ),
                                              Positioned(
                                                  top: 35,
                                                  left: 33,
                                                  child: CircleAvatar(
                                                    radius: 7,
                                                    backgroundColor: documents[
                                                    index]
                                                    [
                                                    'isStats']
                                                        ? Colors.green
                                                        : Colors.green
                                                        .withAlpha(
                                                        0),
                                                  )),
                                            ],
                                          ),
                                          title: Text(
                                            documents[index]
                                            ['username'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          subtitle: documents[index][
                                          'lastMessage'] !=
                                              null
                                              ? Container(
                                            child: documents[
                                            index]
                                            [
                                            'lastMessage'] !=
                                                null
                                                ? Text(
                                              documents[
                                              index]
                                              [
                                              'lastMessage'],
                                              style: TextStyle(
                                                  color: Colors
                                                      .black87,
                                                  wordSpacing:
                                                  1.5,
                                                  letterSpacing:
                                                  0.2,
                                                  fontWeight:
                                                  FontWeight
                                                      .normal,
                                                  fontSize:
                                                  14),
                                            )
                                                : Text(
                                              'file 📁 ',
                                              style: TextStyle(
                                                  color: Colors
                                                      .black87,
                                                  wordSpacing:
                                                  1.5,
                                                  letterSpacing:
                                                  0.2,
                                                  fontWeight:
                                                  FontWeight
                                                      .normal,
                                                  fontSize:
                                                  14),
                                            ),
                                          )
                                              : Container(
                                              child: Text(
                                                'send a first message',
                                                style: TextStyle(
                                                    color: Colors
                                                        .black87,
                                                    wordSpacing:
                                                    1.5,
                                                    letterSpacing:
                                                    0.2,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    fontSize: 14),
                                              )),
                                          //
                                          // Container(
                                          //   margin: EdgeInsets.only(top: 5),
                                          //   child: Text(
                                          //     documents[index]['username'],
                                          //     style: TextStyle(
                                          //         color: Colors.black,
                                          //         fontWeight: FontWeight.normal,fontSize: 13),
                                          //   ),
                                          // ),
                                          trailing: documents[index]
                                          ['timeSend'] !=
                                              null
                                              ? Container(
                                            child: Text(
                                              DateFormat(
                                                  "h:mm a")
                                                  .format(documents[
                                              index]
                                              [
                                              'timeSend']
                                                  .toDate()),
                                              style: const TextStyle(
                                                  color: Colors
                                                      .black87,
                                                  fontSize: 11),
                                            ),
                                          )
                                              : Container(
                                            child: Text(
                                              DateFormat(
                                                  "h:mm a")
                                                  .format(DateTime
                                                  .now()),
                                              style: const TextStyle(
                                                  color: Colors
                                                      .black87,
                                                  fontSize: 11),
                                            ),
                                          ),
                                          onTap: () async {
                                            await Navigator.of(
                                                context)
                                                .push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                          documents[index]
                                                          [
                                                          'username'],
                                                          documents[index]
                                                          [
                                                          'image_url'],
                                                          documents[index]
                                                          ['userId'],
                                                          currentUserId,
                                                          documents[index]
                                                          [
                                                          'isStats']),
                                                ));
                                          })
                                          : Container(), //                           <-- Divider
                                    ),
                                    // Divider(height: 0.02,color: Colors.grey),
                                  ],
                                );
                              }): Container(
                              child: Image.asset('assets/images/b.jpg',
                                width: MediaQuery.of(context).size.width,height: 200,fit: BoxFit.cover,));
                          ;
                        })),
              ],
            ),
          ),
        ),
      ),
      ])
    );
  }
}
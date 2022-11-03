import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';


class ListUserScreen extends StatefulWidget {
  @override
  State<ListUserScreen> createState() => _ListUserScreenState();
}

class _ListUserScreenState extends State<ListUserScreen>
    with WidgetsBindingObserver {
  final _auth = FirebaseAuth.instance;
  late User signedInUser;
 final currentUserId=FirebaseAuth.instance.currentUser!.uid;
  void   SetStatus (bool status)  {
     FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({
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

  void _checkInternetConnection()  async{
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
    if (state == AppLifecycleState.resumed && _isConnected==true ) {
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
          preferredSize: Size.fromHeight(60),
          child: AppBar(
              elevation: 4,
              title: Text('Users'),
              centerTitle: true,
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 15),
                  child: DropdownButton(
                    underline: Container(),
                    icon: Icon(Icons.more_vert,
                        color: Theme.of(context).primaryIconTheme.color,
                        size: 27),
                    items: [
                      DropdownMenuItem(
                        value: 'logout',
                        child: Row(
                          children: const [
                            Icon(Icons.exit_to_app,color: Colors.black,),
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
                      }
                    ,
                  ),
                ),
              ]),
        ),
        body: Container(
            margin: EdgeInsets.only(top: 15),
            child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context,AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final documents = snapshot.data!.docs;
                  print('users ${documents.length}');
                  return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (ctx, index) {
                        var isStats=    documents[index]['isStats'];
                        return Container(
                            padding: EdgeInsets.all(3),
                            margin: EdgeInsets.all(7),
                            child: ListTile(
                                leading: Stack(
                                  children: [
                                  CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(documents[index]['image_url']),
                                           ),
                                    Positioned(
                                        top: 40,
                                        left: 40,
                                        child:
                                        CircleAvatar(
                                          radius: 7,
                                          backgroundColor:
                                          isStats ? Colors.green : Colors.green.withAlpha(0),
                                        )
                            ),

                                  ],),
                                title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                      documents[index]['username'],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                  ),
                                    ),
                                    Container(
                                        child:isStats ? Text('Online',style: TextStyle(fontSize: 12,color: Colors.grey),) :
                                        Text('Offline',style: TextStyle(fontSize: 12,color: Colors.grey))),
                               ] ),
                                onTap: () async {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(documents[index]['username'],documents[index]['image_url'],documents[index]['userId'],currentUserId,documents[index]['isStats']),
                                      ));
                                }));
                      });
                })));
  }
}

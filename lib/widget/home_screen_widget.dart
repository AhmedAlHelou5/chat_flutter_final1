import 'dart:io';

import 'package:advstory/advstory.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_flutter_final/screen/add_story.dart';
import 'package:chat_flutter_final/screen/show_story_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_instagram_stories/flutter_instagram_stories.dart';
import 'package:flutter_story_list/flutter_story_list.dart';
import 'package:intl/intl.dart';
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

  _backFromStoriesAlert() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text(
          "User have looked stories and closed them.",
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18.0),
        ),
        children: <Widget>[
          SimpleDialogOption(
            child: const Text("Dismiss"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  final userData = FirebaseFirestore.instance.collection('users').snapshots();
  final stories = FirebaseFirestore.instance.collection('stories').snapshots();
  var indexx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          //wrap with PreferredSize
          preferredSize: Size.fromHeight(55),
          child: AppBar(
              elevation: 3,
              title: Text('Messages'),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {},
              ),
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 15),
                  child: DropdownButton(
                    underline: Container(),
                    icon: Icon(Icons.menu,
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
                      }
                    },
                  ),
                ),
              ]),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),

              Expanded(
                flex: 1,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('stories')
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final documents = snapshot.data!.docs;
                      print('messages ${documents.length}');
                      return StoryList(
                          onPressedIcon: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddStory()),
                            );
                          },
                          iconBackgroundColor: Colors.pink,
                          addItemWidth: 80,
                          borderColor: Colors.pinkAccent,
                          itemMargin: 8,
                          borderRadius: 5,
                          iconSize: 10,
                          height: 200,
                          addItemBackgroundColor: Theme.of(context).accentColor,
                          image: Icon(Icons.add_a_photo,
                              size: 60, color: Theme.of(context).cardColor),
                          // Image.network(
                          //   documents[indexx]['imageUrl'],
                          //   fit: BoxFit.cover,
                          // ),
                          text: Text(
                            "Create Story",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.pink,
                            ),
                          ),
                          itemCount: documents.length,
                          itemBuilder: (context, index) => InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MoreStories(
                                            documents[index]['username'],
                                            documents[index]['imageUrl'],
                                            documents[index]['userImage'],
                                            )),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 100,
                                          child: Image.network(
                                            documents[index]['imageUrl'],
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Positioned(left: 10,bottom:10,child: FittedBox(child: Text(documents[index]['username'],style: TextStyle(color: Colors.white),)))
                                      ],
                                    )

                                  ],
                                ),
                              ));
                    }),
              ),
              // FlutterInstagramStories(
              //   collectionDbName: 'users',
              //   showTitleOnIcon: true,
              //   backFromStories: () {
              //     _backFromStoriesAlert();
              //   },
              //   iconTextStyle: TextStyle(
              //     fontSize: 14.0,
              //     color: Colors.white,
              //   ),
              //   iconImageBorderRadius: BorderRadius.circular(15.0),
              //   iconBoxDecoration: BoxDecoration(
              //     borderRadius: BorderRadius.all(Radius.circular(15.0)),
              //     color: Color(0xFFffffff),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Color(0xff333333),
              //         blurRadius: 10.0,
              //         offset: Offset(
              //           0.0,
              //           4.0,
              //         ),
              //       ),
              //     ],
              //   ),
              //   iconWidth: 150.0,
              //   iconHeight: 150.0,
              //   textInIconPadding:
              //   EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0),
              //   //how long story lasts in seconds
              //   imageStoryDuration: 7,
              //   progressPosition: ProgressPosition.top,
              //   repeat: true,
              //   inline: false,
              //   languageCode: 'en',
              //   backgroundColorBetweenStories: Colors.black,
              //   closeButtonIcon: Icon(
              //     Icons.close,
              //     color: Colors.white,
              //     size: 28.0,
              //   ),
              //   closeButtonBackgroundColor: Color(0x11000000),
              //   sortingOrderDesc: true,
              //   lastIconHighlight: true,
              //   lastIconHighlightColor: Colors.deepOrange,
              //   lastIconHighlightRadius: const Radius.circular(15.0),
              //   captionTextStyle: TextStyle(
              //     fontSize: 22,
              //     color: Colors.white,
              //   ),
              //   captionMargin: EdgeInsets.only(
              //     bottom: 50,
              //   ),
              //   captionPadding: EdgeInsets.symmetric(
              //     horizontal: 24,
              //     vertical: 8,
              //   ),
              // ),
// AdvStory(
              //   storyCount:5,
              //
              //   storyBuilder: (storyIndex) => Story(
              //     contentCount: 5,
              //     contentBuilder: (contentIndex) => ImageContent(url:stories[storyIndex]['imageUrl']),
              //   ),
              //   trayBuilder: (index) => AdvStoryTray(url: stories[index]['username']),
              // ),
              Expanded(
                flex: 5,
                child: Card(
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10, left: 20),
                        child: Text(
                          'Last Messages',
                          style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          margin: EdgeInsets.only(top: 15, right: 10, left: 10),
                          width: double.infinity,
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('userId', isNotEqualTo: currentUserId)
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
                                return ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: documents.length,
                                    itemBuilder: (ctx, index) {
                                      // var isStats = documents[index]['isStats'];

                                      return Column(
                                        children: [
                                          Container(
                                            child: ListTile(
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
                                              subtitle: Text(
                                                documents[index]
                                                        ['lastMessage'] ??
                                                    'send a first Message',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    wordSpacing: 1.5,
                                                    letterSpacing: 0.2,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 13),
                                              ),
                                              trailing: Text(
                                                DateFormat("h:mm a").format(
                                                    documents[index]['timeSend']
                                                        .toDate()),
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10),
                                              ),
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
                                          ),
                                          // Divider(),

                                          // Divider(height: 0.02,color: Colors.grey),
                                        ],
                                      );
                                    });
                              })),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

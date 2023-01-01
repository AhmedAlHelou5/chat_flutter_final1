import 'dart:io';
import 'package:chat_flutter_final/widget/bottom_sheet_update_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widget/user_image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final _auth = FirebaseAuth.instance;
  late User signedInUser;

  String? image = '';
  String? username = '';
  String? email = '';
  String? phone = '';

  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get()
        .then((value) async {
      if (value.exists) {
        setState(() {
          image = value.data()!['image_url'];
          username = value.data()!['username'];
          email = value.data()!['email'];
          phone = value.data()!['phone'];
        });
      }
    });
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkInternetConnection();
    getCurrentUser();
    print(currentUserId);
    _getDataFromDatabase();
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

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void SetStatus(bool status) {
    FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'isStats': status,
    });
  }

  final _controllerUserName = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerPhone = TextEditingController();
  var enabledEdit = false;
  File? _userImageFile;
  final _formKey = GlobalKey<FormState>();

  void _pickedImage(File? image) {
    _userImageFile = image;
  }

  // var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPhone = '';


  bool showPassword = false;

  void _submitAuthForm(
    String phoneNo,
    String? FullName,
    // File? image,
  ) async {
    // UserCredential authResult;

    // final ref = FirebaseStorage.instance
    //     .ref()
    //     .child('user_image')
    //     .child(currentUserId + '.jpg');
    //
    // await ref.putFile(image!);
    //
    // final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({
      'username': _enteredUsername.isNotEmpty ? FullName:username,
      'phone': _enteredPhone.isNotEmpty ?phoneNo:phone ,
      'userId': currentUserId,
    });

    await FirebaseFirestore.instance
        .collection('stories')
        .doc(currentUserId)
        .update({
      'username': _enteredUsername.isNotEmpty ? FullName:username,
    });
    await FirebaseFirestore.instance
        .collection('last_message')
        .doc(signedInUser.uid)
        .collection(signedInUser.uid).doc(currentUserId)
        .update({
      'username':_enteredUsername.isNotEmpty ? FullName:username,
    });

    await  FirebaseFirestore.instance
        .collection('messages').doc(currentUserId).collection(currentUserId).
    where('userId1',isEqualTo: true).where('userId2',isEqualTo: true).get().then((value) async {

      await FirebaseFirestore.instance
          .collection('messages')
          .doc(signedInUser.uid)
          .collection(signedInUser.uid).doc(currentUserId).
           update({
          'username': _enteredUsername.isNotEmpty ? FullName:username,
           });

    } );





    //   await FirebaseFirestore.instance
  //       .collection('last_message').doc(currentUserId).
  //       update({
  //     'username':_enteredUsername
  // });

    Fluttertoast.showToast(
      msg: "Done Edit",
      textColor: Colors.red,
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        //wrap with PreferredSize
        preferredSize: Size.fromHeight(55),
        child: AppBar(
            elevation: 3,
            leading: Center(
              child: Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            leadingWidth: 100,
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

      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.only(left: 16, top: 25, right: 16),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: ListView(
              children: [
                Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 4,
                                color: Theme.of(context).scaffoldBackgroundColor),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1),
                                  offset: Offset(0, 10))
                            ],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  image!,
                                ))),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: (){
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (builder) => BottomSheetUpdateImage(),
                              );
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 4,
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                ),
                                color: Colors.green,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                buildTextFieldUserName(),
                // buildTextFieldEmail(),
                // Center(
                //   child:Text(_errorMessage, style: TextStyle(color: Colors.red),),
                //
                // ),
                buildTextFieldPhone(),

                SizedBox(
                  height: 35,
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      // padding: EdgeInsets.symmetric(horizontal: 50),
                      // : RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20)),
                      onPressed: () {},
                      child: Text("CANCEL",
                          style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 2.2,
                              color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _submitAuthForm( _enteredPhone, _enteredUsername);
                      },
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.white),
                      ),
                    )

                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFieldUserName() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        key: ValueKey('username'),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: 'Full Name',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: username!,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            )),
        controller: _controllerUserName,
          onChanged: (val) {
            // validateEmail(val);

            if (val.length > 3 && val != '') {
              setState(() {
                _enteredUsername =  val;
              });
            } else {
              setState(() {
                _enteredUsername = username!;
              });
            }
          }
      ),
    );
  }

  // Widget buildTextFieldEmail() {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 35.0),
  //     child: TextFormField(
  //       key: ValueKey('email'),
  //       keyboardType: TextInputType.emailAddress,
  //
  //       decoration: InputDecoration(
  //           contentPadding: EdgeInsets.only(bottom: 3),
  //           labelText: 'E-mail',
  //           floatingLabelBehavior: FloatingLabelBehavior.always,
  //           hintText: email,
  //           hintStyle: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.normal,
  //             color: Colors.black,
  //           )),
  //       controller: _controllerEmail,
  //         onChanged: (val) {
  //           validateEmail(val);
  //
  //           if (val.length > 12 && val != '') {
  //             setState(() {
  //               _enteredEmail =  val;
  //             });
  //           } else {
  //             setState(() {
  //               _enteredEmail = email!;
  //             });
  //           }
  //         }
  //
  //     ),
  //   );
  // }

  Widget buildTextFieldPhone(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        key: ValueKey('phone'),
          keyboardType: TextInputType.number,
          maxLength: 10,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: 'Phone',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: phone ?? 'add Phone',
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            )),
        controller: _controllerPhone,
          onChanged: (val) {
            if (val.length > 9 && val.length < 11 && val != '') {
              setState(() {
                _enteredPhone = '+97 $val';
              });
            } else {
              setState(() {
                _enteredPhone = '+97 $phone';
              });
            }
          }
      ),
    );
  }
  // String _errorMessage = '';

  // void validateEmail(String val) {
  //   if(val.isEmpty){
  //     setState(() {
  //       _errorMessage = "Email can not be empty";
  //     });
  //   }else if(!EmailValidator.validate(val, true)){
  //     setState(() {
  //       _errorMessage = "Invalid Email Address";
  //     });
  //   }else{
  //     setState(() {
  //
  //       _errorMessage = "";
  //     });
  //   }
  // }
}

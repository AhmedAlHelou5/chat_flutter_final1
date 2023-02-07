import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_flutter_final/widget/bottom_sheet_update_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';
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
  final _formKey = GlobalKey<FormState>();
  String? image = '';
  String? username = '';
  String? email = '';
  String? phone = '';
  TextEditingController UserNameController = TextEditingController();
  TextEditingController PhoneController = TextEditingController();
  bool isLoading = false;
   User? user;
  bool _displayNameValid = true;
  bool _bioValid = true;

  // late final void Function(
  //     String phone,
  //     String username,
  //     BuildContext ctx,
  //     ) submitFn;


  // Future<void> _trySubmit() async {
  //   var isValid = _formKey.currentState!.validate();
  //   FocusScope.of(context).unfocus();
  //
  //   if ( _enteredPhone.length !=10 && !_enteredPhone.startsWith('059') ) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Please check the phone  number.'),
  //         backgroundColor: Theme.of(context).errorColor,
  //       ),
  //     );
  //     return ;
  //   }
  //
  //   if (isValid) {
  //     _formKey.currentState!.save();
  //     submitFn(
  //       _enteredPhone,
  //       _enteredUsername,
  //       context,
  //     );
  //   }
  //   print(isValid);
  // }
  // getUser() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   var doc = await usersRef.doc(currentUserId).get();
  //   // user = User.fromDocument(signedInUser);
  //   // displayNameController.text = signedInUser.displayName!;
  //   // bioController.text = user.phoneNumber;
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

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


  // final _controllerEmail = TextEditingController();
  final _controllerPhone = TextEditingController();
  var enabledEdit = false;
  File? _userImageFile;
  // final _formKey = GlobalKey<FormState>();

  void _pickedImage(File? image) {
    _userImageFile = image;
  }

  // var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPhone = '';


  bool showPassword = false;

  // void _submitAuthForm(
  //   String phoneNo,
  //   String? FullName,
  // ) async {
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(currentUserId)
  //       .update({
  //     'username': _enteredUsername.isNotEmpty ? FullName:username,
  //     'phone': _enteredPhone.length>=10 ? phoneNo: phone ,
  //     'userId': currentUserId,
  //   });
  //
  //   await FirebaseFirestore.instance
  //       .collection('stories')
  //       .doc(currentUserId)
  //       .update({
  //     'username': _enteredUsername.isNotEmpty ? FullName:username,
  //   });
  //   await FirebaseFirestore.instance
  //       .collection('last_message')
  //       .doc(signedInUser.uid)
  //       .collection(signedInUser.uid).doc(currentUserId)
  //       .update({
  //     'username':_enteredUsername.isNotEmpty ? FullName:username,
  //   });
  //
  //   await  FirebaseFirestore.instance
  //       .collection('messages').doc(currentUserId).collection(currentUserId).
  //   where('userId1',isEqualTo: true).where('userId2',isEqualTo: true).get().then((value) async {
  //
  //     await FirebaseFirestore.instance
  //         .collection('messages')
  //         .doc(signedInUser.uid)
  //         .collection(signedInUser.uid).doc(currentUserId).
  //          update({
  //         'username': _enteredUsername.isNotEmpty ? FullName:username,
  //          });
  //
  //   } );
  //
  //
  //
  // await  Fluttertoast.showToast(
  //     msg: "Done Edit",
  //     textColor: Colors.red,
  //   );
  //
  // }

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
  Widget build(BuildContext context) {
    UserNameController.text  = username.toString();
    PhoneController.text  = phone.toString();

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
                                image:  NetworkImage(image!))),
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
                // buildTextFieldUserName(),
                //
                // buildTextFieldPhone(),
                buildDisplayNameField(),
                buildPhoneField(),
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
                      onPressed: updateProfileData
                        // else{
                        //   Fluttertoast.showToast(
                        //     msg: "phone must be of 10 numbers and Start 059 and Name more than 3 char",
                        //     textColor: Colors.red,
                        //
                        //
                        //   );
                        // }
                      // },
                    ,  child: Text(
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

  // Widget buildTextFieldUserName() {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 35.0),
  //     child: TextFormField(
  //       key: ValueKey('username'),
  //       keyboardType: TextInputType.text,
  //       decoration: InputDecoration(
  //           contentPadding: EdgeInsets.only(bottom: 3),
  //           labelText: 'Full Name',
  //           floatingLabelBehavior: FloatingLabelBehavior.always,
  //           // hintText: username!,
  //           // enabled: true,
  //
  //           // label: Text(username!),
  //           hintStyle: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.normal,
  //             color: Colors.black,
  //           )),
  //       controller: _controllerUserName,
  //
  //         onChanged: (val) {
  //           // validateEmail(val);
  //
  //           if (val != null) {
  //             setState(() {
  //               username =  val ;
  //
  //               _controllerUserName.text=val;
  //               _enteredUsername=_controllerUserName.text;
  //
  //               print(_controllerUserName.text);
  //                   print(_controllerUserName.text.length);
  //             });
  //           } else {
  //
  //             setState(() {
  //               // username = _enteredUsername;
  //               _controllerUserName.text=val;
  //               _enteredUsername=_controllerUserName.text;
  //
  //             });
  //           }
  //         }
  //     ),
  //   );
  // }
  //
  // // void _backspace() {
  // //   final text = _controllerUserName.text;
  // //   final textSelection = _controllerUserName.selection;
  // //   final selectionLength = textSelection.end - textSelection.start;
  // //
  // //   // There is a selection.
  // //   if (selectionLength > 0) {
  // //     final newText = text.replaceRange(
  // //       textSelection.start,
  // //       textSelection.end,
  // //       '',
  // //     );
  // //     _controllerUserName.text = newText;
  // //     _controllerUserName.selection = textSelection.copyWith(
  // //       baseOffset: textSelection.start,
  // //       extentOffset: textSelection.start,
  // //     );
  // //     return;
  // //   }
  // //
  // //   // The cursor is at the beginning.
  // //   if (textSelection.start == 0) {
  // //     return;
  // //   }
  // //
  // //   // Delete the previous character
  // //   final newStart = textSelection.start - 1;
  // //   final newEnd = textSelection.start;
  // //   final newText = text.replaceRange(
  // //     newStart,
  // //     newEnd,
  // //     '',
  // //   );
  // //   _controllerUserName.text = newText;
  // //   _controllerUserName.selection = textSelection.copyWith(
  // //     baseOffset: newStart,
  // //     extentOffset: newStart,
  // //   );
  // // }
  //
  // Widget buildTextFieldPhone(){
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 35.0),
  //     child: TextFormField(
  //       key: ValueKey('phone'),
  //         keyboardType: TextInputType.number,
  //         maxLength: 10,
  //         // validator: (String? value) {
  //         //   if (value!.length != 10 && !_enteredPhone.startsWith('059')) {
  //         //     return 'Mobile Number must be of 10 digit and Start 059';
  //         //   } else {
  //         //     return '';
  //         //   }
  //         // },
  //         onSaved: (value) {
  //           _enteredPhone = value!;
  //         },
  //         validator: (value) {
  //           if (value!.length != 10 && !_enteredPhone.startsWith('059')) {
  //             return 'Mobile Number must be of 10 digit and Start 059';
  //           }
  //           return null;
  //         },
  //
  //         decoration: InputDecoration(
  //           contentPadding: EdgeInsets.only(bottom: 3),
  //           labelText: 'Phone',
  //           floatingLabelBehavior: FloatingLabelBehavior.always,
  //           hintText: phone ?? 'add Phone',
  //
  //           hintStyle: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.normal,
  //             color: Colors.black,
  //
  //           )),
  //         inputFormatters: <TextInputFormatter>[
  //           FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
  //           FilteringTextInputFormatter.digitsOnly
  //         ],
  //       controller: _controllerPhone ,
  //
  //         // validator: (String? value) {
  //         //   return (value != null && value.contains('059')) ? 'Do not use the (.) char.' : null;
  //         // },
  //         onChanged: (val) {
  //           if (val.length >= 10 && val.length < 11 && val != '') {
  //             setState(() {
  //               // _enteredPhone = '$val';
  //               _enteredPhone =  val;
  //               _controllerPhone.text=val;
  //               // _enteredPhone=_controllerPhone.text;
  //
  //               print(_controllerPhone.text);
  //               print(_controllerPhone.text.length);
  //             });
  //             // Fluttertoast.showToast(
  //             //   msg: "failed  Edit",
  //             //   textColor: Colors.red,
  //             // );
  //
  //           } else {
  //             setState(() {
  //               _enteredPhone = '$phone'  ;
  //               // phone = _enteredPhone;
  //               // _controllerPhone.text=val;
  //               _enteredPhone=_controllerPhone.text;
  //
  //             });
  //           }
  //         }
  //     ),
  //   );
  // }
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
  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Username",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: UserNameController,
          maxLength: 10,

          decoration: InputDecoration(
            hintText: "Update  Username",
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
        )
      ],
    );
  }

  Column buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Phone",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          keyboardType: TextInputType.number,
          maxLength: 10,
          controller: PhoneController,
          inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              FilteringTextInputFormatter.digitsOnly
            ],
          decoration: InputDecoration(
            hintText: "Update Phone",
            errorText: _bioValid ? null : "Phone not correct",
          ),
        )
      ],
    );
  }

  updateProfileData() {
    setState(() {
      UserNameController.text.trim().length < 3 ||
          UserNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      PhoneController.text.trim().length > 10 &&PhoneController.text.startsWith('059')
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.doc(currentUserId).update({
        "username": UserNameController.text,
        "phone": PhoneController.text,
      });
       FirebaseFirestore.instance
          .collection('stories')
          .doc(currentUserId)
          .update({
        'username':UserNameController.text,
      });
       FirebaseFirestore.instance
          .collection('last_message')
          .doc(signedInUser.uid)
          .collection(signedInUser.uid).doc(currentUserId)
          .update({
        'username':UserNameController.text,
      });

        FirebaseFirestore.instance
          .collection('messages').doc(currentUserId).collection(currentUserId).
      where('userId1',isEqualTo: true).where('userId2',isEqualTo: true).get().then((value) async {

        await FirebaseFirestore.instance
            .collection('messages')
            .doc(signedInUser.uid)
            .collection(signedInUser.uid).doc(currentUserId).
        update({
          'username':UserNameController.text,
        });

      } );



        Fluttertoast.showToast(
        msg: "Done Edit",
        textColor: Colors.red,
      );






      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
      
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed updated!'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
  }

  String validateMobile(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length != 10) {
      return 'Mobile Number must be of 10 digit and Start 059';
    } else {
      return '';
    }
  }
}

import 'package:chat_flutter_final/screen/auth_screen.dart';
import 'package:chat_flutter_final/screen/home_screen_with_nav_bottom.dart';
import 'package:chat_flutter_final/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final  storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp());
}
class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization =Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
        future: _initialization,
        builder: (context, appSnapshot) {
          return  MaterialApp(
            title: 'Flutter Chat',
            theme: ThemeData(
                primarySwatch: Colors.pink,
                primaryColor: Colors.pink,
                backgroundColor: Colors.pink,
                accentColor: Colors.pink[50],
                disabledColor: Colors.pink[100],
                accentColorBrightness: Brightness.dark,
                buttonTheme:ButtonTheme.of(context).copyWith(
                  buttonColor: Colors.pink,
                  textTheme: ButtonTextTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                )
            ),
            home: appSnapshot.connectionState != ConnectionState.done ? SplashScreen() :
            StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), builder: (ctx, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return SplashScreen();
              }
              if (userSnapshot.hasData) {
                return HomeScreenWithNavBottom(currentPage: 0);
              }
              return AuthScreen();
            }),

          );

        }
    );
  }
}

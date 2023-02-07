import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String profileImageUrl;
  final String id;
  final String email;
  final String phone;


  const User({
    required this.name,
    required this.profileImageUrl,
    required this.id,
    required this.email,
    required this.phone
  });
  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
       name:  doc['username'],
      phone:  doc['phone'],
      profileImageUrl: doc['photoUrl'],
    );
  }
}
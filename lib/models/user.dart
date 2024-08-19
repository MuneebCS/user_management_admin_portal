import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String fullName;
  final String profileImageUrl;

  User({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.profileImageUrl,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      uid: doc.id,
      email: doc['email'],
      fullName: doc['fullName'],
      profileImageUrl: doc['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
    };
  }
}

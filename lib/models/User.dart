import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  // upload to fireStroe
  final String id;
  final String displayName;
  final String username;
  final String photoUrl;
  final String email;
  final String bio;

  User(
      {this.id,
        this.displayName,
        this.username,
        this.photoUrl,
        this.email,
        this.bio});
// download from fire store
  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc.id,
        email: doc['email'],
        username: doc['username'],
        photoUrl: doc['photoUrl'],
        bio: doc['bio'],
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class storygram{

  // ignore: deprecated_member_use
  static FirebaseUser user;
  static FirebaseFirestore firestore;
  static FirebaseStorage firebaseStorage;
  static SharedPreferences sharedPreferences;
}
//for use in shaer pranfac or firestore collection if we wantand storage
const kAuthCollection='users';
const kid='id';
const kUsername='username';
const kEmail='email';
const kphotoUrl='photoUrl';
const kbio='bio';
const kdisplayName='displayName';
// this for storage and fireStore postes
const kPostsPictures='PostsPictures';
const kPostFirebase='PostFirebase';
const kurl = 'url';
const klocation ='location';
const kdescription= 'description';
const kpostID = 'postID ';
const kownerID = 'ownerID';
const ktime = 'time';
const klikes = 'likes';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class storygram{

  // ignore: deprecated_member_use
  static FirebaseUser user;
  static FirebaseFirestore firestore;
  static SharedPreferences sharedPreferences;
}
//for use in shaer pranfac or firestore collection if we want
const kAuthCollection='users';
const kid='id';
const kUsername='username';
const kEmail='email';
const kUrl='url';
const kbio='bio';
const kprofileName='profileName';
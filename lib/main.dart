import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/pages/homePage.dart';

void main() async {
  //this widget for accec any method or any thing from main void
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   FirebaseFirestore.instance.settings;
   storygram.firestore = FirebaseFirestore.instance;
  storygram.firebaseStorage=FirebaseStorage.instance;
  storygram.sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'storygram',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        dialogBackgroundColor: Colors.black,
        primarySwatch: Colors.grey,
        accentColor: Colors.black,
        cardColor: Colors.white70,
      ),
      home: HomePage(),
    );
  }
}

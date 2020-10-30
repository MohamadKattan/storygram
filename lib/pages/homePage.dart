import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/createAccountPage.dart';
import 'package:storygram/pages/notifictionsPage.dart';
import 'package:storygram/pages/profilePage.dart';
import 'package:storygram/pages/searchPage.dart';
import 'package:storygram/pages/timeLinePage.dart';
import 'package:storygram/pages/upLoadPage.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersReference = FirebaseFirestore.instance.collection(kAuthCollection);
final StorageReference storageReference =
    FirebaseStorage.instance.ref().child(kPostsPictures);
final postsReference = FirebaseFirestore.instance.collection(kPostFirebase);
final DateTime timestamp = DateTime.now();
User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // this to switch if signIN or Not
  bool isSingIn = false;

  // this for switch between pages on home page
  PageController pageController;

  // this for indax pages inside pageView
  int getPageIndex = 0;

  void initState() {
    super.initState();
    // this for switch between pages on home page
    pageController = PageController();

    // switch ifcontrolSignIn: fals OR true
    googleSignIn.onCurrentUserChanged.listen((account) {
      controlSignIn(account);
    }, onError: (e) {
      print('Error Message' + e.toString());
    });

    // alredy have an Accont In AuTH
    googleSignIn.signInSilently(suppressErrors: false).then((gSignAccount) {
      controlSignIn(gSignAccount);
    }).catchError((e) {
      print('Error Message' + e.toString());
    });
  }

  //if user singinIn pushto homeScreen
  Scaffold buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: [
          TimeLinePage(),
          NotificationsPage(),
          //argment to upload page
          UpLoadPage(gCurrentUser: currentUser),
          SearchPage(),
          //argment to profilrPage
          ProfilePage(userProfileId: currentUser),
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        activeColor: Colors.white,
        inactiveColor: Colors.grey,
        backgroundColor: Theme.of(context).accentColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.camera)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

// this for index pages inside pageView&when click on icon for change
  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

//****************************************
//this for SingInScreen if user dosen't singinIn
  Scaffold buildSingInScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomRight,
                colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Story',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Lobster', fontSize: 40),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                loginUser();
              },
              child: Container(
                height: 65.0,
                width: 270.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/3.png'), fit: BoxFit.cover)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // this for finish what will start from init
  void dispode() {
    pageController.dispose();
    super.dispose();
  }

  //this function for register by google account
  loginUser() {
    googleSignIn.signIn();
  }

  //this function for OUT by google account
  logoutUser() {
    googleSignIn.signOut();
  }

  //this function for contr8ol if user Auth or not in FireAuth
  controlSignIn(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      saveUserInfoToFireStore();
      setState(() {
        isSingIn = true;
      });
    } else {
      setState(() {
        isSingIn = false;
      });
    }
  }

  // this function for create and save collection in fireStore
  saveUserInfoToFireStore() async {
    //***
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersReference.doc(user.id).get();

    if (!doc.exists) {
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateAccountPage()));
      //This for upload data to firestore
      usersReference.doc(user.id).set({
        'id': user.id,
        ' displayName': user.displayName,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'bio': '',
        'timestamp': timestamp,
      });
      //download
      doc = await usersReference.doc(user.id).get();
    }
    // this for downlaod data from fireSTORE
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
    print(currentUser.email);
  }

  @override
  Widget build(BuildContext context) {
    if (isSingIn) {
      return buildHomeScreen();
    } else {
      return buildSingInScreen();
    }
  }
}

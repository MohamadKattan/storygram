import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/pages/profilePage.dart';
import 'package:storygram/widget/progressWidget.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
// with AutomaticKeepAliveClientMixin<SearchPage>
{
  TextEditingController searchtextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
// this function for clear text field
  emptyTheTextFormField() {
    searchtextEditingController.clear();
  }

  //this function for get Info ProfileUser from fireStore control show name conect with type litter
  controllerSearching(value) {
    Future<QuerySnapshot> allUsers =
        usersReference.where('username', isGreaterThanOrEqualTo: value).get();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

  //this function for appbarr
  AppBar searchPageHeader() {
    return AppBar(
      backgroundColor: Colors.black,
      title: TextFormField(
        style: TextStyle(fontSize: 18.0, color: Colors.white),
        controller: searchtextEditingController,
        decoration: InputDecoration(
            hintText: 'Search here....',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            filled: true,
            prefixIcon: Icon(
              Icons.person_pin,
              color: Colors.white,
              size: 30.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: emptyTheTextFormField,
            )),
        //this show result when you will start type name conect with litter
        onFieldSubmitted: (value) {
          controllerSearching(value);
        },
      ),
    );
  }

  // this function for screen no found user data
  Container displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
          child: ListView(
        shrinkWrap: true,
        children: [
          Icon(
            Icons.group,
            color: Colors.grey,
            size: 200,
          ),
          Text('SearchUser',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 65.0)),
        ],
      )),
    );
  }

  // this function for if found data and get date from quary snapshot
  displayUserScreen() {
    return FutureBuilder<QuerySnapshot>(
      future: futureSearchResults,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgres();
        }
        List<UserResult> searchUserResult = [];
        dataSnapshot.data.docs.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          searchUserResult.add(userResult);
        });
        return ListView(
          children: searchUserResult,
        );
      },
    );
  }

  // bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchPageHeader(),
      // in body for switch if found date user or not
      body: futureSearchResults == null
          ? displayNoSearchResultScreen()
          : displayUserScreen(),
    );
  }
}

// this class show Info after got from snapShot
class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.grey,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => disPlayUserProfile(context,userProfileId:eachUser.id),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage:
                      // NetworkImage( storygram.sharedPreferences.getString(kUrl)),

                      CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.username,
                  // storygram.sharedPreferences.getString(kprofileName),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  eachUser.email,
                  // storygram.sharedPreferences.getString(kUsername),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //this method for push argment another user id to profile page
  disPlayUserProfile(BuildContext context,{String userProfileId}){
 Navigator.push(context, MaterialPageRoute(builder:(context)=>ProfilePage(userProfileId:userProfileId) ));

  }
}

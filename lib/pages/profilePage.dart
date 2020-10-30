import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/editProfilePage.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/widget/headerWidget.dart';
import 'package:storygram/widget/progressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  //argment from homepage for get dat from User
  final User userProfileId;
  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // this for bool inside createButton
  final String currentOnlineUserId = currentUser?.id;
  // this method for view data profile
  creatProfileTopView() {
    return FutureBuilder(
      future: usersReference.doc(widget.userProfileId.id.toString()).get(),
      builder: (context, dataSnapShot) {
        if (!dataSnapShot.hasData) {
          return CircularProgres();
        }
        User user = User.fromDocument(dataSnapShot.data);
        return Padding(
          padding: EdgeInsets.all(17.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 45.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        //*1 this for number: {posts/followers/following}
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createColumns('posts', 0),
                            createColumns('followers', 0),
                            createColumns('following', 0),
                          ],
                        ),
                        Row(
                          children: [
                            createButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 13.0),
                  child: Text(
                    user.username.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                    user.email.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 3.0),
                  child: Text(
                    user.bio,
                    style: TextStyle(color: Colors.white70, fontSize: 18.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //*1 this for number: {posts/followers/following}
  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

// *2 this for follow/UnFollowButton
  createButton() {
    // ignore: unrelated_type_equality_checks
    bool ownProfile = currentOnlineUserId == widget.userProfileId.id.toString();
    if (ownProfile) {
      //*3this if it is my profile fpr edit
      // performFunction: editUserProfile
      return createButtonTitleAndFunction(
        title: 'EditProfile',
      );
    }
  }

  // Function performFunction
// *3this if it is my profile fpr edit
  Container createButtonTitleAndFunction({
    String title,
  }) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: 3.0),
        child: FlatButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                      currentOnlineUserId: currentOnlineUserId))),
          child: Container(
            width: 180.0,
            height: 26.0,
            child: Text(
              title,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6.0)),
          ),
        ),
      ),
    );
  }

// *3this if it is my profile fpr edit
//   editUserProfile() {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) =>
//                 EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: 'Profile'),
      body: ListView(
        children: [
          creatProfileTopView(),
        ],
      ),
    );
  }
}

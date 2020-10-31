import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/editProfilePage.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/widget/headerWidget.dart';
import 'package:storygram/widget/postTileWidget.dart';
import 'package:storygram/widget/postWidget.dart';
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
  // this for if Profile post is true or not
  bool loading = false;
  //for cunt Number posts
  int countPost = 0;
  //this list for postes that came from fireStore PostCollection
  List<Post> postList = [];
  String postOraintion = 'grid';
  // ignore: must_call_super
  void initState() {
    //for get data from fireStore PostCollection
    getAllProfilePosts();
  }

  // this for bool inside createButton
  final String currentOnlineUserId = currentUser?.id;
  // this method for view data profile
  creatProfileTopView() {
    return FutureBuilder(
      future: usersReference.doc(widget.userProfileId.id.toString()).get(),
      builder: (context, dataSnapShot) {
        if (!dataSnapShot.hasData) {
          return circularProgres();
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

// *3 this if it is my profile for edit Info
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
          Divider(),
          createListAndGRIDPostOrintion(),
          Divider(
            height: 0.0,
          ),
          disPlayProfilePost(),
        ],
      ),
    );
  }

  disPlayProfilePost() {
    if (loading) {
      return circularProgres();
    } else if (postList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.all(30.0),
                child: Icon(
                  Icons.photo_library,
                  size: 200,
                  color: Colors.grey,
                )),
            Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No POST YET',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold),
                ))
          ],
        ),
      );
    } else if (postOraintion == 'grid') {
      List<GridTile> gridTileList = [];
      postList.forEach((eachPost) {
        gridTileList.add(GridTile(child: PostTile(eachPost)));
      });
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        physics: NeverScrollableScrollPhysics(),
        children: gridTileList,
      );
    } else if (postOraintion == 'list') {
      return Column(
        children: postList,
      );
    }
  }

//this method for get from fireStor postCollection
  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await postsReference
        .doc(widget.userProfileId.id)
        .collection(kuserPostscollection)
        .orderBy(ktime, descending: true)
        .get();
    setState(() {
      loading = false;
      countPost = querySnapshot.docs.length;
      postList = querySnapshot.docs
          .map((docsSnapShot) => Post.fromDocument(docsSnapShot))
          .toList();
    });
  }

  createListAndGRIDPostOrintion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => setOraintion('grid'),
          icon: Icon(Icons.grid_on),
          color: postOraintion == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setOraintion('list'),
          icon: Icon(Icons.grid_on),
          color: postOraintion == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  // this method for swithch bettwen view Way by grid or list
  setOraintion(String oraintion) {
    setState(() {
      this.postOraintion = oraintion;
    });
  }
}

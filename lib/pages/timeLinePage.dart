import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/widget/headerWidget.dart';
import 'package:storygram/widget/postWidget.dart';
import 'package:storygram/widget/progressWidget.dart';

class TimeLinePage extends StatefulWidget {
  // argmaint from home page for set data
  final User gCurrentUser;
  TimeLinePage({this.gCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
//Post list for retevier data for show as List in this page from post widget
  List<Post> post;
  //Post list for retevier data for show as List in this page from fireStore
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    retrieveTimeLine();
    retrieveFollowings();
  }

//this method for view poste all user = to their id automatic in timePage
  retrieveTimeLine() async {
    QuerySnapshot querySnapshot = await timelineReference
        .doc(widget.gCurrentUser.id)
        .collection(ktimelinePostsColl)
        .orderBy('timestamp', descending: false)
        .get();

    List<Post> allPosts = querySnapshot.docs
        .map((document) => Post.fromDocument(document))
        .toList();

    setState(() {
      this.post = allPosts;
    });
  }
//this method for view Followings  = to their id automatic in timePage
  retrieveFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .doc(currentUser.id)
        .collection(kUserFollowingColl)
        .get();
    setState(() {
      followingsList =
          querySnapshot.docs.map((document) => document.id).toList();
    });
  }
  //this methof for show posts with id in list view
  creatUserTimeLine()
  {
    if(post==null)
    {
      return circularProgres();
    }
    else
      {
        return ListView(children: post);
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(child: creatUserTimeLine(),onRefresh: ()=>retrieveTimeLine(),),
    );
  }
}

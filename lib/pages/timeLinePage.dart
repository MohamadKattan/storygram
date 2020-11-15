// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:storygram/constent.dart';
// import 'package:storygram/models/User.dart';
// import 'package:storygram/pages/editProfilePage.dart';
// import 'package:storygram/pages/homePage.dart';
// import 'package:storygram/widget/headerWidget.dart';
// import 'package:storygram/widget/postTileWidget.dart';
// import 'package:storygram/widget/postWidget.dart';
// import 'package:storygram/widget/progressWidget.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// class TimeLinePage extends StatefulWidget {
//   //argment from homepage for get dat from User
//   final User userProfileId;
//   TimeLinePage({this.userProfileId});
//
//   @override
//   _TimeLinePageState createState() => _TimeLinePageState();
// }
//
// class _TimeLinePageState extends State<TimeLinePage> {
//   int countTotalFollowers = 0;
//   int countTotalFollowing = 0;
//   bool following = false;
//   // this for if Profile post is true or not
//   bool loading = false;
//   //for cunt Number posts
//   int countPost = 0;
//   //this list for postes that came from fireStore PostCollection
//   List<Post> postList = [];
//   //for switch view way to listView or gridview
//   String postOraintion = 'grid';
//   // ignore: must_call_super
//   void initState() {
//     //for get data from fireStore PostCollection
//     getAllProfilePosts();
//
//   }
//
//
//
//   // this for bool inside createButton
//   final String currentOnlineUserId = currentUser?.id;
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: header(context, isAppTitle: true ),
//       body: ListView(
//         children: [
//           createListAndGRIDPostOrintion(),
//           Divider(
//             height: 0.0,
//           ),
//           disPlayProfilePost(),
//         ],
//       ),
//     );
//   }
//
// //this method if userProfile page found his posts or no post
//   disPlayProfilePost() {
//     if (loading) {
//       return circularProgres();
//     } else if (postList.isEmpty) {
//       return Container(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//                 padding: EdgeInsets.all(30.0),
//                 child: Icon(
//                   Icons.photo_library,
//                   size: 200,
//                   color: Colors.grey,
//                 )),
//             Padding(
//                 padding: EdgeInsets.all(20.0),
//                 child: Text(
//                   'No POST YET',
//                   style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 40.0,
//                       fontWeight: FontWeight.bold),
//                 ))
//           ],
//         ),
//       );
//     }
//     else if (postOraintion == 'grid') {
//       List<GridTile> gridTileList = [];
//       postList.forEach((eachPost) {
//         gridTileList.add(GridTile(child: PostTile(eachPost)));
//       });
//       return GridView.count(
//         crossAxisCount: 3,
//         shrinkWrap: true,
//         childAspectRatio: 1.0,
//         mainAxisSpacing: 1.5,
//         crossAxisSpacing: 1.5,
//         physics: NeverScrollableScrollPhysics(),
//         children: gridTileList,
//       );
//     } else if (postOraintion == 'list') {
//       return Column(
//         children: postList,
//       );
//     }
//   }
//
// //this method for get from fireStor postCollection
//   getAllProfilePosts() async {
//     setState(() {
//       loading = true;
//     });
//     QuerySnapshot querySnapshot = await postsReference
//         .doc(widget.userProfileId.id)
//         .collection(kuserPostscollection)
//         .orderBy('timestamp', descending: true)
//         .get();
//     setState(() {
//       loading = false;
//       postList = querySnapshot.docs
//           .map((docsSnapShot) => Post.fromDocument(docsSnapShot))
//           .toList();
//     });
//   }
//
// //this for view list or grid
//   createListAndGRIDPostOrintion() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         IconButton(
//           onPressed: () => setOraintion('grid'),
//           icon: Icon(Icons.grid_on),
//           color: postOraintion == 'grid'
//               ? Theme.of(context).primaryColor
//               : Colors.grey,
//         ),
//         IconButton(
//           onPressed: () => setOraintion('list'),
//           icon: Icon(Icons.list),
//           color: postOraintion == 'grid'
//               ? Theme.of(context).primaryColor
//               : Colors.grey,
//         ),
//       ],
//     );
//   }
//
//   // this method for swithch bettwen view Way by grid or list
//   setOraintion(String oraintion) {
//     setState(() {
//       this.postOraintion = oraintion;
//     });
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/models/allPosts.dart';
import 'package:storygram/widget/headerWidget.dart';
import 'package:storygram/widget/progressWidget.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage>
    with AutomaticKeepAliveClientMixin<TimeLinePage> {
  final String postID;
  final String postOwnerid;
  final String postImageUrl;
  _TimeLinePageState({this.postID, this.postImageUrl, this.postOwnerid});
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: (StreamBuilder<QuerySnapshot>(
        stream: storygram.firestore
            .collection('timeline')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        // ignore: missing_return
        builder: (context, dataSnapShot) {
          if (!dataSnapShot.hasData) {
            return circularProgres();
          }
          List<AllPosts> allPosts = [];
          dataSnapShot.data.docs.forEach((document) {
            allPosts.add(AllPosts.fromDocument(document));
          });
          return ListView(
            children: allPosts,
          );
        },
      )),
    );
  }
}

class AllPosts extends StatelessWidget {
  final String id;
  final String postID;
  final String ownerID;
  final dynamic likes;
  final String username;
  final String description;
  final String url;
  final String location;
  final Timestamp timestamp;
  AllPosts(
      {this.postID,
      this.id,
      this.ownerID,
      this.description,
      this.likes,
      this.username,
      this.location,
      this.url,
      this.timestamp});
  factory AllPosts.fromDocument(DocumentSnapshot doc) {
    return AllPosts(
      id: doc.id,
      postID: doc['postID'],
      ownerID: doc['ownerID'],
      username: doc['username'],
      likes: doc['likes'],
      url: doc['url'],
      description: doc['description'],
      location: doc['location'],
      timestamp: doc['timestamp'],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Center(
            child: Image(
          image: NetworkImage(url),
        )),
      ),
    );
  }
}

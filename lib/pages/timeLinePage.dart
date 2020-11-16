import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/commentPage.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/pages/profilePage.dart';
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

class AllPosts extends StatefulWidget {
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

  // this method for count Number likes
  int getNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    } else {
      int counter = 0;
      likes.values.forEach((eachValues) {
        if (eachValues == true) {
          counter = counter + 1;
        }
      });
      return counter;
    }
  }

  @override
  _AllPostsState createState() => _AllPostsState(
      postID: this.postID,
      ownerID: this.ownerID,
      likes: this.likes,
      username: this.username,
      description: this.description,
      url: this.url,
      location: this.location,
      likesCount: getNumberOfLikes(this.likes));
}

class _AllPostsState extends State<AllPosts> {
  final String postID;
  final String ownerID;
  final String username;
  final String description;
  final String url;
  final String location;
  final String currentOnlineUserId = currentUser?.id;
  Map likes;
  bool isLiked;
  int likesCount;
  bool showHeart = false;
  _AllPostsState(
      {this.likesCount,
      this.ownerID,
      this.postID,
      this.url,
      this.username,
      this.description,
      this.location,
      this.likes});

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          createPostHead(),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: GestureDetector(
                  onDoubleTap: () => controlUserLikePost(),
                  child: Stack(
                    children: [
                      Image(
              image: NetworkImage(widget.url),

            ),
                      Center(
                        child: showHeart
                            ? Icon(
                          Icons.favorite,
                          size: 140,
                          color: Colors.pink,
                        )
                            : Text(''),
                      ),
                    ],
                  ),
                )),
          ),
          creatPostFooter(),
        ],
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
      future: usersReference.doc(widget.ownerID).get(),
      // ignore: missing_return
      builder: (context, dataSnapShot) {
        if (!dataSnapShot.hasData) {
          return circularProgres();
        }
        User user = User.fromDocument(dataSnapShot.data);
        bool isPostOwner = currentOnlineUserId == widget.ownerID;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
              onTap: () => disPlayUserProfile(context, userProfileId: user.id),
              child: Text(
                user.username,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          subtitle: Text(
            widget.location,
            style: TextStyle(color: Colors.white),
          ),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onPressed: () => print('Delete'),
                )
              : Text(''),
        );
      },
    );
  }

  controlUserLikePost() {
    bool _liked = widget.likes[currentOnlineUserId] == true;
    try {
      if (_liked) {
        postsReference
            .doc(widget.ownerID)
            .collection(kuserPostscollection)
            .doc(widget.postID)
            .update({'likes.$currentOnlineUserId': false});
        removeLike();
        setState(() {
          likesCount = likesCount - 1;
          isLiked = false;
          widget.likes[currentOnlineUserId] = false;
        });
      } else if (!_liked) {
        postsReference
            .doc(widget.ownerID)
            .collection(kuserPostscollection)
            .doc(widget.postID)
            .update({'likes.$currentOnlineUserId': true});

        addLike();
        setState(() {
          likesCount = likesCount + 1;
          isLiked = true;
          widget.likes[currentOnlineUserId] = true;
          showHeart = true;
        });
        Timer(Duration(milliseconds: 800), () {
          setState(() {
            showHeart = false;
          });
        });
      }
    } catch (convertPlatformException) {
      throw convertPlatformException(e);
    }
  }

  removeLike() {
    try {
      bool isNotPostOwnerId = currentOnlineUserId != widget.ownerID;
      if (isNotPostOwnerId) {
        activityFeedReference
            .doc(widget.ownerID)
            .collection('feedItems')
            .doc(widget.postID)
            .get()
            .then((document) {
          if (document.exists) {
            document.reference.delete();
          }
        });
      }
    } catch (exremoveLike) {
      print(exremoveLike);
    }
  }

  // this method for add like if not our post to feedItems
  addLike() {
    try {
      bool isNotPostOwner = currentOnlineUserId != ownerID;
      if (isNotPostOwner) {
        activityFeedReference
            .doc(ownerID)
            .collection('feedItems')
            .doc(postID)
            .set({
          'type': 'like',
          'username': currentUser.username,
          'userId': currentUser.id,
          'timestamp': DateTime.now(),
          'url': url,
          'postId': postID,
          'userProfileImg': currentUser.photoUrl,
        });
      }
    } catch (exaddLike) {
      print(exaddLike.toString());
    }
  }

  disPlayComment(BuildContext context,
      {String postID, String ownerID, String url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      //argment to Comment Page
      return CommentPage(
          postID: postID, postOwnerid: ownerID, postImageUrl: url);
    }));
  }

  creatPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
              child: GestureDetector(
                onTap: () => controlUserLikePost(),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 28.0,
                  color: Colors.pink,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0, top: 40.0),
              child: GestureDetector(
                onTap: () => disPlayComment(context,
                    url: widget.url,
                    postID: widget.postID,
                    ownerID: widget.ownerID),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Text('$likesCount likes',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Text(
                  '${widget.username} ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
            Expanded(
                child: Text('${widget.description}',
                    style: TextStyle(color: Colors.white))),
          ],
        ),
      ],
    );
  }

  disPlayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: userProfileId,
                )));
  }
}

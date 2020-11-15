import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/commentPage.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/pages/profilePage.dart';
import 'package:storygram/widget/progressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Post extends StatefulWidget {
  //this data implement from Upload page for read data post
  final String postID;
  final String ownerID;
  final dynamic likes;
  final String username;
  final String description;
  final String url;
  final String location;
  Post(
      {this.postID,
      this.ownerID,
      this.username,
      this.likes,
      this.description,
      this.url,
      this.location});
  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postID: documentSnapshot['postID'],
      ownerID: documentSnapshot['ownerID'],
      location: documentSnapshot['location'],
      likes: documentSnapshot['likes'],
      url: documentSnapshot['url'],
      username: documentSnapshot['username'],
      description: documentSnapshot['description'],
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
  _PostState createState() => _PostState(
      postID: this.postID,
      ownerID: this.ownerID,
      likes: this.likes,
      username: this.username,
      description: this.description,
      url: this.url,
      location: this.location,
      likesCount: getNumberOfLikes(this.likes));
}

//Not: in the up we creat data&&likesCOUNT FOR READ POST took from uploadPage after AFTER THAT implamnt iside _PostState for using
class _PostState extends State<Post> {
  final String postID;
  final String ownerID;
  final String username;
  final String description;
  final String url;
  final String location;
  final String currentOnlineUserId = currentUser?.id;
  Map likes;
  int likesCount;
  bool isLiked;
  bool showHeart = false;

  _PostState(
      {this.postID,
      this.ownerID,
      this.likes,
      this.username,
      this.description,
      this.url,
      this.location,
      this.likesCount});
  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          createPostHead(),
          creatPostPicture(),
          creatPostFooter(),
        ],
      ),
    );
  }

// this method to know if our post or another from currentUserid
  createPostHead() {
    return FutureBuilder(
      future: usersReference.doc(ownerID).get(),
      // ignore: missing_return
      builder: (context, dataSnapShot) {
        if (!dataSnapShot.hasData) {
          return circularProgres();
        }
        User user = User.fromDocument(dataSnapShot.data);
        bool isPostOwner = currentOnlineUserId == ownerID;
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
            location,
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

  // this method for catch picture
  creatPostPicture() {
    return GestureDetector(
      onDoubleTap: () => controlUserLikePost(),
      child:
      Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(url),
          showHeart
              ? Icon(
                  Icons.favorite,
                  size: 140,
                  color: Colors.pink,
                )
              : Text(''),
        ],
      ),
    );
  }

//******************************backend
  //this method for like or dilike
  controlUserLikePost() {
    bool _liked = likes[currentOnlineUserId] == true;
    if (_liked) {
      postsReference
          .doc(ownerID)
          .collection(kuserPostscollection)
          .doc(postID)
          .update({'likes.$currentOnlineUserId': false});
      removeLike();
      setState(() {
        likesCount = likesCount - 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    } else if (!_liked) {
      postsReference
          .doc(ownerID)
          .collection(kuserPostscollection)
          .doc(postID)
          .update({'likes.$currentOnlineUserId': true});

      addLike();
      setState(() {
        likesCount = likesCount + 1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  //this method for dislike if not our post to feedItems
  removeLike() {
    try {
      bool isNotPostOwnerId = currentOnlineUserId != ownerID;
      if (isNotPostOwnerId) {
        activityFeedReference
            .doc(ownerID)
            .collection('feedItems')
            .doc(postID)
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

//*****************************
// this method for display comment
  disPlayComment(BuildContext context,
      {String postID, String ownerID, String url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      //argment to Comment Page
      return CommentPage(
          postID: postID, postOwnerid: ownerID, postImageUrl: url);
    }));
  }

//this method for postPictureALL daiteles (clicik favort ,coment,userName,discrpstion)in the downefrom page front
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
                    postID: postID, ownerID: ownerID, url: url),
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
                  '$username ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
            Expanded(
                child: Text('$description',
                    style: TextStyle(color: Colors.white))),
          ],
        ),
      ],
    );
  }

  //this method for push argment another user id to profile page
  disPlayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: userProfileId,
                )));
  }
}

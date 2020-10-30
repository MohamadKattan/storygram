import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/widget/progressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Post extends StatefulWidget {
  //this data implamnt from UPload page for read data post
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
      this.likes,
      this.username,
      this.description,
      this.url,
      this.location});
  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postID: documentSnapshot['postID'],
      ownerID: documentSnapshot['ownerID'],
      location: documentSnapshot['location'],
      likes: documentSnapshot[' likes'],
      url: documentSnapshot[' url'],
      username: documentSnapshot[' username'],
      description: documentSnapshot[' description'],
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
              onTap: () => print('go go '),
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
      onDoubleTap: () => print('it is liked'),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
         Image.network(url),
        ],
      ),
    );
  }

//this method for postPictureALL daiteles
  creatPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
              child: GestureDetector(
                onTap: () => print('post is liked'),
                child: Icon(Icons.favorite,color:Colors.pink,size: 28.0,)
                // Icon(
                //   isLiked ? Icons.favorite : Icons.favorite_border,
                //   size: 28.0,
                //   color: Colors.pink,
                // ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => print('ShowComment'),
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
}

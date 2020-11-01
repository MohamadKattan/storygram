import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/widget/headerWidget.dart';
import 'package:storygram/widget/progressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as tago;

class CommentPage extends StatefulWidget {
  final String postID;
  final String postOwnerid;
  final String postImageUrl;
  CommentPage({this.postID, this.postImageUrl, this.postOwnerid});
  @override
  _CommentPageState createState() => _CommentPageState(
      postID: postID, postOwnerid: postOwnerid, postImageUrl: postImageUrl);
}

class _CommentPageState extends State<CommentPage> {
  final String postID;
  final String postOwnerid;
  final String postImageUrl;
  _CommentPageState({this.postID, this.postImageUrl, this.postOwnerid});
  TextEditingController commentEditingController = TextEditingController();

  //this method for save data comment in fire store
  saveComment() {
    // if my comment
    commentsReference.doc(postID).collection(kCommentCollection).add({
      'username': currentUser.username,
      'userId': currentUser.id,
      'url': currentUser.photoUrl,
      'comment': commentEditingController,
      'timestamp': DateTime.now(),
    });
    //this bool if it is not my post for another user write comment to me
    bool isNotPostOwnerId = postOwnerid != currentUser.id;
    if (isNotPostOwnerId) {
      activityFeedReference
          .doc(postOwnerid)
          .collection(kFeedItemCollection)
          .add({
        'type': 'comment',
        'commentData': timestamp,
        'postID': postID,
        'userId': currentUser.id,
        'userProfileUrl': currentUser.photoUrl,
        'username': currentUser.username,
        'url': postImageUrl,
      });
    }
    commentEditingController.clear();
  }

//this method for get data comment from fireStore
  retrieveComment() {
    return StreamBuilder(
      stream: commentsReference
          .doc(postID)
          .collection(kCommentCollection)
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, dataSnapShot) {
        if (!dataSnapShot.hasData) {
          return circularProgres();
        }
        List<Comment> comments = [];
        dataSnapShot.data.documents.forEach((document) {
          comments.add(Comment.fromDocument(document));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: 'Comments'),
      body: Column(
        children: [
          Expanded(
            child: retrieveComment(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: commentEditingController,
              decoration: InputDecoration(
                labelText: 'Write your comment here',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            trailing: OutlineButton(
              onPressed: saveComment,
              borderSide: BorderSide.none,
              child: Text(
                'Publish your comment',
                style: TextStyle(
                    color: Colors.lightGreenAccent,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  Comment({this.username, this.userId, this.url, this.comment, this.timestamp});
  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      username: documentSnapshot['username'],
      userId: documentSnapshot['userId'],
      url: documentSnapshot['url'],
      comment: documentSnapshot['comment'],
      timestamp: documentSnapshot['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              title: Text(
                username + ': ' + comment,
                style: TextStyle(color: Colors.black, fontSize: 18.0),
              ),
              leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(url)),
              subtitle: Text(
                tago.format(timestamp.toDate()),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/pages/postScreenPage.dart';
import 'package:storygram/pages/profilePage.dart';
import 'package:storygram/widget/headerWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storygram/widget/progressWidget.dart';
import 'package:timeago/timeago.dart' as tago;

class NotificationsPage extends StatefulWidget {
  @override
  _NotifictionPageState createState() => _NotifictionPageState();
}

class _NotifictionPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: 'Notifications'),
      body: Container(
        child: FutureBuilder(
          future: retrivedNotifictions(),
          builder: (context,dataSnapShot)
          {
            if(!dataSnapShot.hasData)
            {
              return circularProgres();
            }
            return ListView(children: dataSnapShot.data);
          },
        ),
      ),
    );
  }

//this method for get data from fire base to this page
  retrivedNotifictions() async {
    QuerySnapshot querySnapshot = await activityFeedReference
        .doc(currentUser.id)
        .collection(kFeedItemCollection)
        .orderBy('timestamp', descending: true)
        .limit(60)
        .get();

    List<NotificationsItem> notificationsItem = [];
    querySnapshot.docs.forEach((document) {
      notificationsItem.add(NotificationsItem.fromDocument(document));
    });
    return notificationsItem;
  }
}

String notificationsItemText;
Widget mediaPreView;

class NotificationsItem extends StatelessWidget {
  //this class for Recive data from fireStore Collections and show in the list [notificationsItem]inside futuerbuldir
  final String username;
  final String type;
  final String commentData;
  final String postID;
  final String userId;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;
  final User eachUser;
  NotificationsItem(
      {this.username,
      this.type,
      this.commentData,
      this.postID,
      this.userId,
      this.userProfileImg,
      this.url,
      this.timestamp,
      this.eachUser});
  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot) {
    return NotificationsItem(
      username: documentSnapshot['username'],
      type: documentSnapshot['type'],
      commentData: documentSnapshot['commentData'],
      postID: documentSnapshot['postID'],
      userId: documentSnapshot['userId'],
      userProfileImg: documentSnapshot['userProfileImg'],
      url: documentSnapshot['url'],
      timestamp: documentSnapshot['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    ConfigerMediaPreVuew(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => disPlayUserProfile(context, userNotProfileId: userId+username),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontSize: 14.0, color: Colors.black),
                children: [
                  TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  //this for topic the message notfication
                  TextSpan(text: '$notificationsItemText'),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            tago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreView,
        ),
      ),
    );
  }

// the metod to switch if user follow or not when they push notfction
  ConfigerMediaPreVuew(context) {
    if (type == 'comment' || type == 'like') {
      mediaPreView = GestureDetector(
        onTap:()=> disPlayFullPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(url))),
            ),
          ),
        ),
      );
    }
    else
      {
        mediaPreView = Text('');
      }
     if(type=='like')
      {
        notificationsItemText='liked your post';
      }
     else if(type=='comment')
    {
      notificationsItemText='replied:$commentData';
    }
     else if(type=='follow')
    {
      notificationsItemText='Started following you';
    }
  else
    {
      notificationsItemText='Error.uknowen type=$type';
    }
  }

  //this method tp puch post to screen post if like or comment
  disPlayFullPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreenPage(
                  postId: postID,
                  userId: userId,
                )));
  }

  //this method for push argment another user id to profile page
  disPlayUserProfile(BuildContext context, {String userNotProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userNotProfileId: userNotProfileId,
                )));
  }

}

// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AllPosts {
//   final String id;
//   final String postID;
//   final String ownerID;
//   final dynamic likes;
//   final String username;
//   final String description;
//   final String url;
//   final String location;
//   final Timestamp timestamp;
//   AllPosts(
//       {this.postID,
//       this.id,
//       this.ownerID,
//       this.description,
//       this.likes,
//       this.username,
//       this.location,
//       this.url,
//       this.timestamp});
//
//   factory AllPosts.fromDocument(DocumentSnapshot doc) {
//     return AllPosts(
//       id: doc.id,
//       postID: doc['postID'],
//       ownerID: doc['ownerID'],
//       username: doc['username'],
//       likes: doc['likes'],
//       url: doc['url'],
//       description: doc['description'],
//       location: doc['location'],
//       timestamp: doc['timestamp'],
//     );
//   }
// }

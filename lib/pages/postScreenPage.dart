import 'package:flutter/material.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/widget/headerWidget.dart';
import 'package:storygram/widget/postWidget.dart';
import 'package:storygram/widget/progressWidget.dart';

class PostScreenPage extends StatelessWidget {
  final String postId;
  final String userId;
  PostScreenPage({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsReference
          .doc(userId)
          .collection(kuserPostscollection)
          .doc(postId)
          .get(),
      builder: (context, dataSnapShot) {
        if (!dataSnapShot.hasData) {
          return circularProgres();
        }
        Post post = Post.fromDocument(dataSnapShot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, strTitle: post.description),
            body: ListView(
              children: [
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

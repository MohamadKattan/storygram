import 'package:flutter/material.dart';
import 'package:storygram/pages/postScreenPage.dart';
import 'package:storygram/widget/postWidget.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  disPlayFullPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
               PostScreenPage(postId: post.postID, userId: post.ownerID)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => disPlayFullPost(context),
      child: Image.network(post.url),
    );
  }
}

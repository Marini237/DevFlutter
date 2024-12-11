import 'package:flutter/material.dart';
import 'package:newflutterapp/components/interactions/interactions.dart';
import 'package:newflutterapp/components/miniprofile.dart';
import 'package:newflutterapp/components/shared_post.dart';
import 'package:newflutterapp/models/post.dart' as models;

class Post extends StatelessWidget {
  final models.Post post;
  final int shareCount;

  const Post({super.key, required this.post, this.shareCount = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Profile Picture + Username)
            MiniProfile(user: post.owner),
            if (post.content != null) ...[
              const SizedBox(height: 10),
              // Text Content
              Text(
                post.content!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (post.image != null) ...[
              const SizedBox(height: 10),
              // Optional Post Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.image!),
              ),
            ],
            // Shared Post
            if (post.embededPost != null) ...[
              const SizedBox(height: 10),
              SharedPost(post: post.embededPost!),
            ],
            const SizedBox(height: 10),
            // Action Buttons (Like, Share, Comment)
            Interactions(
              likeCount: post.likes.length,
              commentCount: post.comments.fold(0, _getNbComments),
              shareCount: shareCount,
              onLike: onLike,
              onComment: onComment,
              onShare: onShare,
            )
          ],
        ),
      ),
    );
  }

  void onLike() {}

  void onComment() {}

  void onShare() {}

  int _getNbComments(int value, models.Post aPost) {
    return aPost.comments.fold(value, _getNbComments) + 1;
  }
}

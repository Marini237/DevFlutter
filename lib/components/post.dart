import 'package:flutter/material.dart';
import 'package:newflutterapp/components/interactions/interactions.dart';
import 'package:newflutterapp/components/miniprofile.dart';
import 'package:newflutterapp/components/shared_post.dart';
import 'package:newflutterapp/models/post.dart' as models;
import 'package:newflutterapp/pages/post_detail.dart';
import 'package:provider/provider.dart';
import 'package:newflutterapp/provider/like_provider.dart';

class PostWidget extends StatelessWidget {
  final models.Post post;
  final int shareCount;

  const PostWidget({super.key, required this.post, this.shareCount = 0});

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
            MiniProfile(user: post.owner),
            if (post.content != null) ...[
              const SizedBox(height: 10),
              Text(post.content!, style: const TextStyle(fontSize: 14)),
            ],
            if (post.image != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.image!),
              ),
            ],
            if (post.embededPost != null) ...[
              const SizedBox(height: 10),
              SharedPost(post: post.embededPost!),
            ],
            const SizedBox(height: 10),
            Interactions(
              postId: post.hashCode,
              commentCount: post.comments.length,
              shareCount: post.shares,
              onComment: () => _handleComment(context),
              onShare: () => _handleShare(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleComment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post: post),
      ),
    );
  }

  void _handleShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post partagé avec succès !')),
    );
  }
}

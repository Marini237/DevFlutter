import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newflutterapp/components/interactions/comment.dart';
import 'package:newflutterapp/components/interactions/like.dart';
import 'package:newflutterapp/components/interactions/share.dart';
import 'package:newflutterapp/provider/like_provider.dart';

class Interactions extends StatelessWidget {
  final int postId;
  final int commentCount;
  final int shareCount;

  final VoidCallback onComment;
  final VoidCallback onShare;

  const Interactions({
    super.key,
    required this.postId,
    required this.onComment,
    required this.onShare,
    required this.commentCount,
    required this.shareCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Gestion des likes via LikeProvider
        Consumer<LikeProvider>(
          builder: (context, likeProvider, child) {
            final likeCount = likeProvider.getLikeCount(postId);
            final hasLiked = likeProvider.hasLiked(postId, "currentUserId");

            return Like(
              onLike: () => likeProvider.toggleLike(postId, "currentUserId"),
              likeCount: likeCount,
              hasLiked: hasLiked,
            );
          },
        ),
        // Gestion des commentaires
        Comment(
          onComment: onComment,
          commentCount: commentCount,
        ),
        // Gestion des partages
        Share(
          onShare: onShare,
          shareCount: shareCount,
        ),
      ],
    );
  }
}

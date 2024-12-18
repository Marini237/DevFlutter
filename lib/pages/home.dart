import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../provider/comment_provider.dart';
import '../provider/like_provider.dart';
import '../provider/share_provider.dart';
import '../components/interactions/like.dart';
import '../components/interactions/comment.dart';
import '../components/interactions/share.dart';
import 'post_detail.dart';

class HomePage extends StatelessWidget {
  final List<Post> posts;

  const HomePage({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil utilisateur (image et nom)
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(post.owner.avatar),
                    ),
                    const SizedBox(width: 10),
                    Text(post.owner.username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),

                // Contenu du post
                if (post.content != null) Text(post.content!),
                if (post.image != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(post.image!, fit: BoxFit.cover),
                  ),
                ],

                const SizedBox(height: 10),

                // Actions (Likes, Comments, Shares)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Gestion des likes
                    Consumer<LikeProvider>(
                      builder: (context, likeProvider, _) {
                        final likeCount =
                            likeProvider.getLikeCount(post.hashCode);
                        final hasLiked = likeProvider.hasLiked(
                            post.hashCode, 'currentUserId');
                        return Like(
                          likeCount: likeCount,
                          onLike: () => likeProvider.toggleLike(
                              post.hashCode, 'currentUserId'),
                          hasLiked: hasLiked,
                        );
                      },
                    ),

                    // Gestion des commentaires
                    Consumer<CommentProvider>(
                      builder: (context, commentProvider, _) {
                        final commentCount =
                            commentProvider.getComments(post.hashCode).length;
                        return Comment(
                          commentCount: commentCount,
                          onComment: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailPage(post: post),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Gestion des partages
                    Consumer<ShareProvider>(
                      builder: (context, shareProvider, _) {
                        final shareCount =
                            shareProvider.getShareCount(post.hashCode);
                        return Share(
                          shareCount: shareCount,
                          onShare: () {
                            shareProvider.addShare(post.hashCode);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Post partagé avec succès !')),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

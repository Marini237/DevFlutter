import 'package:flutter/material.dart';
import 'package:newflutterapp/models/post.dart' as models;
import 'package:newflutterapp/pages/post_detail.dart';
import 'package:newflutterapp/components/interactions/comment.dart';
import 'package:newflutterapp/components/interactions/like.dart';
import 'package:newflutterapp/components/interactions/share.dart';

class HomePage extends StatelessWidget {
  final List<models.Post> posts;

  const HomePage({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Social Network'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Affiche l'auteur du post
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(post.owner.avatar),
                  ),
                  title: Text(post.owner.username),
                  subtitle: Text(post.content ?? 'Sans contenu'),
                ),
                if (post.image != null)
                  Image.network(
                    post.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                const SizedBox(height: 8),
                // Boutons de Like, Comment, Share
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Bouton Like
                    Like(
                      likeCount: post.likes.length,
                      onLike: () {
                        if (!post.likes.contains(post.owner)) {
                          post.likes.add(post.owner);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Post liké!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Vous avez déjà liké ce post.')),
                          );
                        }
                      },
                    ),
                    // Bouton Comment
                    Comment(
                      commentCount: post.comments.length,
                      onComment: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailPage(post: post),
                          ),
                        );
                      },
                    ),
                    // Bouton Share
                    Share(
                      shareCount: post.shares,
                      onShare: () {
                        post.shares++;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post partagé!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../components/interactions/like.dart';
import '../components/interactions/comment.dart' as interactions;
import '../components/interactions/share.dart';
import 'post_detail.dart';
import '../provider/comment_provider.dart' as provider;
import '../provider/like_provider.dart';
import '../provider/share_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Stream<QuerySnapshot> getPostsStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucune publication disponible.'));
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;
            final postId = snapshot.data!.docs[index].id;
            final userId =
                FirebaseAuth.instance.currentUser?.uid ?? 'unknownUser';

            final likeCount = post['likes'] != null ? post['likes'].length : 0;
            final hasLiked = post['likes']?.contains(userId) ?? false;

            final commentCount = post['commentCount'] ?? 0;

            final shareCount = post['shares'] ?? 0;

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
                          radius: 40,
                          backgroundImage: post['owner']['avatar'] != null
                              ? NetworkImage(post['owner']['avatar'])
                              : null,
                          child: post['owner']['avatar'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          post['owner']['username'] ?? 'Nom inconnu',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Contenu du post
                    if (post['content'] != null) Text(post['content']),
                    if (post['image'] != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(post['image'], fit: BoxFit.cover),
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
                            return Like(
                              likeCount: likeCount,
                              onLike: () {
                                if (hasLiked) {
                                  FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(postId)
                                      .update({
                                    'likes': FieldValue.arrayRemove([userId])
                                  });
                                } else {
                                  FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(postId)
                                      .update({
                                    'likes': FieldValue.arrayUnion([userId])
                                  });
                                }
                              },
                              hasLiked: hasLiked,
                            );
                          },
                        ),

                        // Gestion des commentaires
                        Consumer<provider.CommentProvider>(
                          builder: (context, commentProvider, _) {
                            return interactions.Comment(
                              commentCount: commentCount,
                              onComment: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return _CommentBottomSheet(postId: postId);
                                  },
                                );
                              },
                            );
                          },
                        ),

                        // Gestion des partages
                        Consumer<ShareProvider>(
                          builder: (context, shareProvider, _) {
                            return Share(
                              shareCount: shareCount,
                              onShare: () {
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId)
                                    .update({
                                  'shares': FieldValue.increment(1),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Post partagé avec succès !')),
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
      },
    );
  }
}

class _CommentBottomSheet extends StatelessWidget {
  final String postId;

  const _CommentBottomSheet({required this.postId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _commentController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Commentaires',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aucun commentaire.'));
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment =
                        comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(comment['authorName'] ?? 'Anonyme'),
                      subtitle: Text(comment['content'] ?? ''),
                      trailing: Text(comment['timestamp'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Ajouter un commentaire',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (newComment) async {
              if (newComment.isNotEmpty) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final commentId = FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .doc()
                      .id;

                  final commentData = {
                    'id': commentId,
                    'postId': postId,
                    'content': newComment,
                    'userId': user.uid,
                    'authorName': user.displayName ?? 'Anonyme',
                    'authorAvatar':
                        user.photoURL ?? 'https://via.placeholder.com/150',
                    'timestamp': DateTime.now().toIso8601String(),
                    'likeCount': 0,
                    'likedBy': [],
                  };

                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .doc(commentId)
                      .set(commentData);

                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .update({'commentCount': FieldValue.increment(1)});

                  _commentController.clear();
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comments.dart';
import '../provider/comment_provider.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final user = _auth.currentUser;

      if (user != null) {
        // Récupération des données utilisateur dans Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur : Utilisateur introuvable.')),
          );
          return;
        }

        final userData = userDoc.data() ?? {};

        // Configuration des champs du commentaire
        final authorAvatar = userData['avatar']?.isNotEmpty == true
            ? userData['avatar']
            : 'https://via.placeholder.com/150'; // URL par défaut

        final authorName = userData['username'] ?? 'Anonyme';

        final comment = Comment(
          id: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.postId)
              .collection('comments')
              .doc()
              .id,
          postId: widget.postId,
          content: _commentController.text,
          userId: user.uid,
          authorName: authorName,
          authorAvatar: authorAvatar,
          timestamp: DateTime.now(),
        );

        try {
          await Provider.of<CommentProvider>(context, listen: false)
              .addComment(widget.postId, comment);
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.postId)
              .update({'commentCount': FieldValue.increment(1)});
          _commentController.clear();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l’ajout du commentaire.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour commenter.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du Post')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section des commentaires.
            StreamBuilder<List<Comment>>(
              stream: Provider.of<CommentProvider>(context)
                  .getRootComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                        child: Text('Aucun commentaire pour le moment.')),
                  );
                }

                final comments = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(comment.authorAvatar),
                        onBackgroundImageError: (_, __) {
                          // Utiliser une image par défaut en cas d'erreur
                          setState(() {
                            comment.authorAvatar =
                                'https://via.placeholder.com/150';
                          });
                        },
                      ),
                      title: Text(comment.authorName),
                      subtitle: Text(comment.content),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            onPressed: () {
                              Provider.of<CommentProvider>(context,
                                      listen: false)
                                  .toggleLike(widget.postId, comment.id,
                                      _auth.currentUser!.uid);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.reply),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentRepliesPage(
                                    postId: widget.postId,
                                    commentId: comment.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Ajouter un commentaire...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _addComment,
            ),
          ],
        ),
      ),
    );
  }
}

class CommentRepliesPage extends StatefulWidget {
  final String postId;
  final String commentId;

  const CommentRepliesPage({
    super.key,
    required this.postId,
    required this.commentId,
  });

  @override
  _CommentRepliesPageState createState() => _CommentRepliesPageState();
}

class _CommentRepliesPageState extends State<CommentRepliesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réponses')),
      body: StreamBuilder<List<Comment>>(
        stream: Provider.of<CommentProvider>(context)
            .getReplies(widget.postId, widget.commentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('Aucune réponse pour le moment.')),
            );
          }

          final replies = snapshot.data!;

          return ListView.builder(
            itemCount: replies.length,
            itemBuilder: (context, index) {
              final reply = replies[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(reply.authorAvatar),
                  onBackgroundImageError: (_, __) {
                    // Utiliser une image par défaut en cas d'erreur
                    setState(() {
                      reply.authorAvatar = 'https://via.placeholder.com/150';
                    });
                  },
                ),
                title: Text(reply.authorName),
                subtitle: Text(reply.content),
                trailing: Text(
                  reply.timestamp.toString(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

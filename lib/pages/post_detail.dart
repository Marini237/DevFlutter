import 'package:flutter/material.dart';
import 'package:newflutterapp/models/post.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final Map<Post, TextEditingController> _replyControllers = {};

  @override
  void dispose() {
    _commentController.dispose();
    _replyControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de ${widget.post.owner.username}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.image != null)
                      Image.network(
                        widget.post.image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      widget.post.content ?? 'Pas de contenu disponible',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.thumb_up, color: Colors.blue),
                            const SizedBox(width: 5),
                            Text('${widget.post.likes.length} Likes'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.comment, color: Colors.green),
                            const SizedBox(width: 5),
                            Text('${widget.post.comments.length} Commentaires'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.share, color: Colors.orange),
                            const SizedBox(width: 5),
                            Text('${widget.post.shares} Partages'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Commentaires',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    for (var comment in widget.post.comments)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '- ${comment.content ?? "Sans contenu"}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.thumb_up,
                                          color: Colors.blue),
                                      onPressed: () {
                                        setState(() {
                                          comment.likes.add(widget.post.owner);
                                        });
                                      },
                                    ),
                                    Text('${comment.likes.length}'),
                                    IconButton(
                                      icon: const Icon(Icons.reply,
                                          color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          if (!_replyControllers
                                              .containsKey(comment)) {
                                            _replyControllers[comment] =
                                                TextEditingController();
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (_replyControllers.containsKey(comment))
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _replyControllers[comment],
                                        decoration: const InputDecoration(
                                          hintText: 'Écrire une réponse...',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_replyControllers[comment]!
                                            .text
                                            .isNotEmpty) {
                                          setState(() {
                                            comment.replies.add(
                                              Post(
                                                owner: widget.post.owner,
                                                content:
                                                    _replyControllers[comment]!
                                                        .text,
                                              ),
                                            );
                                            _replyControllers[comment]!.clear();
                                          });
                                        }
                                      },
                                      child: const Text('Envoyer'),
                                    ),
                                  ],
                                ),
                              ),
                            if (comment.replies.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Réponses :',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    for (var reply in comment.replies)
                                      Text(
                                          '- ${reply.content ?? "Sans contenu"}'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Écrivez votre commentaire...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      setState(() {
                        widget.post.comments.add(
                          Post(
                            owner: widget.post.owner,
                            content: _commentController.text,
                          ),
                        );
                        _commentController.clear();
                      });
                    }
                  },
                  child: const Text('Envoyer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

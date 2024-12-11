import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final int commentCount;
  final VoidCallback onComment;

  const Comment({
    super.key,
    required this.onComment,
    required this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: () {
            // Logique de navigation ou d'action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ouverture des commentaires')),
            );
            onComment(); // Appel du callback pour la logique supplémentaire
          },
          icon: const Icon(Icons.comment_outlined),
          tooltip: "Voir les commentaires",
        ),
        Text(
          '$commentCount',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

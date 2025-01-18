import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final int commentCount;
  final VoidCallback onComment;
  final bool isEnabled; // Pour activer/désactiver le bouton

  const Comment({
    super.key,
    required this.commentCount,
    required this.onComment,
    this.isEnabled = true, // Par défaut, le bouton est activé
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed:
              isEnabled ? onComment : null, // Désactivé si `isEnabled` est faux
          icon: Icon(
            Icons.comment_outlined,
            color: isEnabled ? Colors.blue : Colors.grey,
          ),
          tooltip: "Comment",
        ),
        Text(
          '$commentCount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isEnabled ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}

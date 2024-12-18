import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final int commentCount;
  final VoidCallback onComment;

  const Comment(
      {super.key, required this.commentCount, required this.onComment});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onComment,
          icon: const Icon(Icons.comment_outlined),
          tooltip: "Comment",
        ),
        Text(
          '$commentCount',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

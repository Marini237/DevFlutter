import 'package:flutter/material.dart';

class Like extends StatelessWidget {
  final int likeCount;
  final VoidCallback onLike;
  final bool hasLiked;

  const Like({
    super.key,
    required this.likeCount,
    required this.onLike,
    required this.hasLiked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onLike,
          icon: Icon(
            hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            color: hasLiked ? Colors.blue : Colors.grey,
          ),
          tooltip: "Like",
        ),
        Text(
          '$likeCount',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

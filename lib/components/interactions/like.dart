import 'package:flutter/material.dart';

class Like extends StatelessWidget {
  final int likeCount;
  final VoidCallback onLike;

  const Like({
    super.key,
    required this.onLike,
    required this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      IconButton(
        onPressed: onLike,
        icon: const Icon(Icons.thumb_up),
        tooltip: "Like",
      ),
      Text('$likeCount'),
    ]);
  }
}

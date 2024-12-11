import 'package:flutter/material.dart';
import 'package:newflutterapp/models/post.dart';

class SharedPost extends StatelessWidget {
  final Post post;

  const SharedPost({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(post.owner.avatar),
                ),
                const SizedBox(width: 10),
                Text(
                  post.owner.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            if (post.content != null)
              Text(
                post.content!,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            if (post.image != null && post.content != null)
              const SizedBox(height: 5),
            if (post.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.image!),
              ),
          ],
        ),
      ),
    );
  }

  void onTap() {}
}

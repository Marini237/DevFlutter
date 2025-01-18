import 'package:flutter/material.dart';
import '../models/post.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final int depth;

  const PostWidget({Key? key, required this.post, this.depth = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (depth > 2) {
      return const Text('Embedded post limit reached');
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.owner.username),
            if (post.content != null && post.content!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(post.content!, style: const TextStyle(fontSize: 14)),
            ],
            if (post.image != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ],
            FutureBuilder<Post?>(
              future: post.fetchEmbeddedPost(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data != null) {
                  return PostWidget(post: snapshot.data!, depth: depth + 1);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 10),
            Text('Comments: ${post.comments.length}'),
            Text('Shares: ${post.shares}'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:newflutterapp/models/user.dart';
import 'package:newflutterapp/models/post.dart';

class ProfilePage extends StatelessWidget {
  final User user;
  final List<Post> userPosts;

  const ProfilePage({super.key, required this.user, required this.userPosts});
  int getTotalComments() {
    int totalComments = 0;
    for (var post in userPosts) {
      totalComments += post.comments.length;
    }
    return totalComments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.avatar),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      user.username,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Publications : ${userPosts.length}'),
                  Text('Commentaires reçus : ${getTotalComments()}'),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userPosts.length,
              itemBuilder: (context, index) {
                final post = userPosts[index];
                return ListTile(
                  title: Text(post.content ?? 'Sans contenu'),
                  leading: post.image != null
                      ? Image.network(post.image!,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.post_add),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

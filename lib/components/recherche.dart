import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../pages/profile.dart';

class RecherchePage extends StatefulWidget {
  final List<Post> posts;

  const RecherchePage({super.key, required this.posts});

  @override
  _RecherchePageState createState() => _RecherchePageState();
}

class _RecherchePageState extends State<RecherchePage> {
  String searchQuery = '';
  List<Post> filteredPosts = [];

  @override
  void initState() {
    super.initState();
    filteredPosts = widget.posts;
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredPosts = widget.posts
          .where((post) =>
              (post.content != null &&
                  post.content!.toLowerCase().contains(query.toLowerCase())) ||
              post.owner.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: updateSearch,
            ),
          ),
          Expanded(
            child: filteredPosts.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () => _navigateToProfile(context, post),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(post.owner.avatar),
                            ),
                          ),
                          title: GestureDetector(
                            onTap: () => _navigateToProfile(context, post),
                            child: Text(
                              post.owner.username,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          subtitle: post.content != null
                              ? Text(
                                  post.content!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () => _navigateToProfile(context, post),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'Aucun résultat trouvé.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context, Post post) {
    final userPosts =
        widget.posts.where((p) => p.owner.id == post.owner.id).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          user: post.owner,
          userPosts: userPosts,
        ),
      ),
    );
  }
}

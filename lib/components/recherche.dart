import 'package:flutter/material.dart';
import 'package:newflutterapp/models/post.dart';
import 'package:newflutterapp/pages/profile.dart';

class RecherchePage extends StatefulWidget {
  final List<Post> posts; // Liste complète des posts à rechercher

  const RecherchePage({super.key, required this.posts});

  @override
  _RecherchePageState createState() => _RecherchePageState();
}

class _RecherchePageState extends State<RecherchePage> {
  String searchQuery = ''; // Texte de la recherche
  List<Post> filteredPosts = []; // Liste des posts filtrés

  @override
  void initState() {
    super.initState();
    filteredPosts = widget.posts; // Initialement, tous les posts sont affichés
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredPosts = widget.posts
          .where((post) =>
              post.content != null &&
              post.content!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged:
                  updateSearch, // Met à jour les résultats au fur et à mesure
            ),
          ),
          Expanded(
            child: filteredPosts.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      Post post = filteredPosts[index];
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(
                                  user: post.owner,
                                  userPosts: widget.posts
                                      .where((p) => p.owner == post.owner)
                                      .toList(),
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(post.owner.avatar),
                          ),
                        ),
                        title: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(
                                  user: post.owner,
                                  userPosts: widget.posts
                                      .where((p) => p.owner == post.owner)
                                      .toList(),
                                ),
                              ),
                            );
                          },
                          child: Text(post.owner.username),
                        ),
                      );
                    },
                  )
                : Center(
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
}

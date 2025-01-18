import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/post.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final User? user;
  final List<Post>? userPosts;

  const ProfilePage({
    Key? key,
    this.user,
    this.userPosts,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  firebase_auth.User? currentUser;
  User? userProfile;
  List<Post> userPosts = [];
  bool isLoading = true;

  final TextEditingController _postContentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndPosts();
  }

  Future<void> _loadUserProfileAndPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      currentUser = firebaseUser;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final postsQuery = await FirebaseFirestore.instance
          .collection('posts')
          .where('owner.id', isEqualTo: firebaseUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        userProfile = userDoc.exists
            ? User.fromJson(userDoc.data()!)
            : User(
                id: firebaseUser.uid,
                username: 'Utilisateur Inconnu',
                avatar: '',
              );
        userPosts =
            postsQuery.docs.map((doc) => Post.fromJson(doc.data())).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement : $e')),
      );
    }
  }

  Future<void> _updateProfileDetails() async {
    final TextEditingController _usernameController =
        TextEditingController(text: userProfile?.username);
    final TextEditingController _bioController =
        TextEditingController(text: userProfile?.bio);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier les détails du profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Biographie',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newUsername = _usernameController.text.trim();
                final newBio = _bioController.text.trim();

                if (newUsername.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser?.uid)
                        .update({
                      'username': newUsername,
                      'bio': newBio,
                    });

                    // Mettre à jour les publications de l'utilisateur
                    final userPostsQuery = await FirebaseFirestore.instance
                        .collection('posts')
                        .where('owner.id', isEqualTo: currentUser?.uid)
                        .get();

                    for (var doc in userPostsQuery.docs) {
                      await doc.reference.update({
                        'owner.username': newUsername,
                      });
                    }

                    setState(() {
                      userProfile = User(
                        id: userProfile!.id,
                        username: newUsername,
                        avatar: userProfile!.avatar,
                        bio: newBio,
                      );
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Détails du profil mis à jour !')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : $e')),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfilePicture() async {
    final TextEditingController _avatarUrlController =
        TextEditingController(text: userProfile?.avatar);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier la photo de profil'),
          content: TextField(
            controller: _avatarUrlController,
            decoration: const InputDecoration(
              labelText: 'Nouvelle URL de la photo',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newAvatarUrl = _avatarUrlController.text.trim();
                if (newAvatarUrl.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser?.uid)
                        .update({'avatar': newAvatarUrl});

                    // Mettre à jour les publications de l'utilisateur
                    final userPostsQuery = await FirebaseFirestore.instance
                        .collection('posts')
                        .where('owner.id', isEqualTo: currentUser?.uid)
                        .get();

                    for (var doc in userPostsQuery.docs) {
                      await doc.reference.update({
                        'owner.avatar': newAvatarUrl,
                      });
                    }

                    setState(() {
                      userProfile = User(
                        id: userProfile!.id,
                        username: userProfile!.username,
                        avatar: newAvatarUrl,
                        bio: userProfile!.bio,
                      );
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Photo de profil mise à jour !')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : $e')),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPostWithUrl() async {
    final content = _postContentController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (content.isEmpty && imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Le contenu ou une URL d\'image est requis.')),
      );
      return;
    }

    try {
      final newPost = Post(
        id: FirebaseFirestore.instance.collection('posts').doc().id,
        owner: userProfile!,
        content: content.isNotEmpty ? content : null,
        image: imageUrl.isNotEmpty ? imageUrl : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likes: [],
        comments: [],
        shares: 0,
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(newPost.id)
          .set(newPost.toJson());

      setState(() {
        userPosts.add(newPost);
        _imageUrlController.clear();
        _postContentController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publication ajoutée avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de l\'ajout de la publication : $e')),
      );
    }
  }

  Future<void> _updatePostImage(Post post) async {
    final TextEditingController _newImageUrlController =
        TextEditingController(text: post.image);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier l\'image de la publication'),
          content: TextField(
            controller: _newImageUrlController,
            decoration: const InputDecoration(
              labelText: 'Nouvelle URL de l\'image',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newImageUrl = _newImageUrlController.text.trim();
                if (newImageUrl.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(post.id)
                        .update({'image': newImageUrl});

                    setState(() {
                      userPosts[userPosts.indexOf(post)] = Post(
                        id: post.id,
                        owner: post.owner,
                        content: post.content,
                        image: newImageUrl, // Nouvelle image
                        createdAt: post.createdAt,
                        updatedAt: DateTime.now(),
                        likes: post.likes,
                        comments: post.comments,
                        shares: post.shares,
                      );
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Image de la publication mise à jour.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : $e')),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(Post post) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .delete();

      setState(() {
        userPosts.remove(post);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publication supprimée avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur lors de la suppression de la publication : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userProfile?.username ?? 'Profil'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _updateProfileDetails,
            tooltip: 'Modifier le profil',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _updateProfilePicture,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                userProfile?.avatar.isNotEmpty == true
                                    ? NetworkImage(userProfile!.avatar)
                                    : null,
                            child: userProfile?.avatar.isEmpty == true
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userProfile?.username ?? 'Nom inconnu',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(userProfile?.bio ??
                                  'Aucune biographie disponible.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _postContentController,
                          decoration: const InputDecoration(
                            labelText: 'Nouvelle publication',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL de l\'image',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _addPostWithUrl,
                          child: const Text('Publier'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  userPosts.isEmpty
                      ? const Text('Aucune publication disponible.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) {
                            final post = userPosts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (post.content != null)
                                      Text(
                                        post.content!,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    if (post.image != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Image.network(
                                          post.image!,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Publié le : ${post.createdAt}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () =>
                                                  _updatePostImage(post),
                                              tooltip: 'Modifier l\'image',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () =>
                                                  _deletePost(post),
                                              tooltip:
                                                  'Supprimer la publication',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}

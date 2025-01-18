import 'user.dart';
import 'comments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  User owner;
  String? content;
  String? image;
  String? embeddedPostId;
  List<Comment> comments; // Remplace List<String> par List<Comment>
  List<String> likes;
  DateTime? createdAt;
  DateTime? updatedAt;
  int shares;

  Post({
    required this.id,
    required this.owner,
    this.content,
    this.image,
    this.embeddedPostId,
    List<Comment>? comments,
    List<String>? likes,
    this.createdAt,
    this.updatedAt,
    this.shares = 0,
  })  : comments = comments ?? [],
        likes = likes ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner.toJson(),
      if (content != null) 'content': content,
      if (image != null) 'image': image,
      if (embeddedPostId != null) 'embeddedPostId': embeddedPostId,
      'comments': comments
          .map((c) => c.toJson())
          .toList(), // Convertir les commentaires en JSON
      'likes': likes,
      'shares': shares,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      owner: User.fromJson(json['owner']),
      content: json['content'] ?? '',
      image: json['image'] ?? '',
      embeddedPostId: json['embeddedPostId'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null),
      likes: json['likes'] != null ? List<String>.from(json['likes']) : [],
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((c) => Comment.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
      shares: json['shares'] ?? 0,
    );
  }

  Future<Post?> fetchEmbeddedPost() async {
    if (embeddedPostId == null) {
      return null;
    }
    try {
      final embeddedPostJson = await fetchPostById(embeddedPostId!);
      return Post.fromJson(embeddedPostJson);
    } catch (e) {
      print('Erreur lors du chargement du post intégré : $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchPostById(String postId) async {
    // Implémentez la logique réelle ici (Firebase, API, etc.)
    throw UnimplementedError();
  }
}

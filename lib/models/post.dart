import 'user.dart';

class Post {
  final User owner;
  final String? content;
  final String? image;
  final Post? embededPost;
  final List<Post> comments;
  final List<String> likes;
  int shares;

  Post({
    required this.owner,
    this.content,
    this.image,
    this.embededPost,
    List<Post>? comments,
    List<String>? likes,
    this.shares = 0,
  })  : comments = comments ?? [],
        likes = likes ?? [];
}

import 'user.dart';

class Post {
  final User owner;
  final String? content;
  final String? image;
  final Post? embededPost;
  final List<Post> comments;
  final List<User> likes;
  final List<Post> replies;
  int shares;

  Post({
    required this.owner,
    this.content,
    this.image,
    this.embededPost,
    List<Post>? comments,
    List<User>? likes,
    this.shares = 0,
    List<Post>? replies,
  })  : comments = comments ?? [],
        likes = likes ?? [],
        replies = replies ?? [];
}

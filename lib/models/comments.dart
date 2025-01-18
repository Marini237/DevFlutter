class Comment {
  final String id;
  final String postId;
  final String content;
  final String userId;
  final String authorName;
  String authorAvatar; // Remove final
  final DateTime timestamp;
  final String? parentCommentId;
  int likeCount;
  Set<String> likedBy;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.userId,
    required this.authorName,
    required this.authorAvatar, // Remove final
    required this.timestamp,
    this.parentCommentId,
    this.likeCount = 0,
    Set<String>? likedBy,
  }) : likedBy = likedBy ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'content': content,
        'userId': userId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'timestamp': timestamp.toIso8601String(),
        'parentCommentId': parentCommentId,
        'likeCount': likeCount,
        'likedBy': likedBy.toList(),
      };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'],
        postId: json['postId'],
        content: json['content'],
        userId: json['userId'],
        authorName: json['authorName'] ?? 'Anonyme', // Valeur par défaut
        authorAvatar: json['authorAvatar'] ??
            'https://images.pexels.com/photos/3373745/pexels-photo-3373745.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', // Avatar par défaut
        timestamp: DateTime.parse(json['timestamp']),
        parentCommentId: json['parentCommentId'],
        likeCount: json['likeCount'],
        likedBy: Set<String>.from(json['likedBy'] ?? []),
      );
}

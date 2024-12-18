import 'package:flutter/material.dart';
import '../models/post.dart';

class CommentProvider extends ChangeNotifier {
  final Map<int, List<Post>> _comments = {};
  List<Post> getComments(int postId) {
    return _comments[postId] ?? [];
  }

  void addComment(int postId, Post comment) {
    if (_comments[postId] == null) {
      _comments[postId] = [];
    }
    _comments[postId]!.add(comment);
    notifyListeners();
  }
}

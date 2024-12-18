import 'package:flutter/material.dart';

class LikeProvider extends ChangeNotifier {
  final Map<int, Set<String>> _likes = {};
  int getLikeCount(int postId) {
    return _likes[postId]?.length ?? 0;
  }

  bool hasLiked(int postId, String userId) {
    return _likes[postId]?.contains(userId) ?? false;
  }

  void toggleLike(int postId, String userId) {
    if (_likes[postId] == null) {
      _likes[postId] = {};
    }
    if (_likes[postId]!.contains(userId)) {
      _likes[postId]!.remove(userId);
    } else {
      _likes[postId]!.add(userId);
    }
    notifyListeners();
  }
}

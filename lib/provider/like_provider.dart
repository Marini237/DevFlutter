import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LikeProvider extends ChangeNotifier {
  final Map<int, Set<String>> _likes = {};

  LikeProvider() {
    _loadLikes();
  }

  // Récupérer le nombre de likes pour un post donné
  int getLikeCount(int postId) {
    return _likes[postId]?.length ?? 0;
  }

  // Vérifier si un utilisateur a liké un post donné
  bool hasLiked(int postId, String userId) {
    return _likes[postId]?.contains(userId) ?? false;
  }

  // Basculer l'état de like pour un utilisateur et un post donné
  void toggleLike(int postId, String userId) {
    if (postId < 0 || userId.isEmpty) return; // Validation des entrées

    _likes[postId] ??= {};

    if (_likes[postId]!.contains(userId)) {
      _likes[postId]!.remove(userId);
    } else {
      _likes[postId]!.add(userId);
    }

    _saveLikes(); // Persister les changements
    notifyListeners();
  }

  // Charger les likes depuis le stockage local
  Future<void> _loadLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final likesString = prefs.getString('likes');
    if (likesString != null) {
      final decoded = Map<String, dynamic>.from(
        Map.castFrom<dynamic, dynamic, String, dynamic>(
          jsonDecode(likesString),
        ),
      );
      _likes.clear();
      decoded.forEach((key, value) {
        _likes[int.parse(key)] = Set<String>.from(value);
      });
    }
    notifyListeners();
  }

  // Sauvegarder les likes dans le stockage local
  Future<void> _saveLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _likes.map((key, value) => MapEntry(key.toString(), value.toList())),
    );
    await prefs.setString('likes', encoded);
  }
}

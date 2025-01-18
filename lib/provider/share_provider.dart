import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ShareProvider extends ChangeNotifier {
  final Map<int, int> _shares = {};

  ShareProvider() {
    _loadShares(); // Charger les partages à l'initialisation
  }

  // Récupérer le nombre de partages d'un post spécifique
  int getShareCount(int postId) {
    return _shares[postId] ?? 0;
  }

  // Ajouter un partage à un post
  void addShare(int postId) {
    if (postId < 0) return; // Validation : postId doit être valide

    _shares[postId] = (_shares[postId] ?? 0) + 1;

    _saveShares(); // Sauvegarder après ajout
    notifyListeners();
  }

  // Réinitialiser les partages d'un post spécifique
  void resetShare(int postId) {
    if (_shares.containsKey(postId)) {
      _shares[postId] = 0;

      _saveShares(); // Sauvegarder après réinitialisation
      notifyListeners();
    }
  }

  // Charger les partages depuis le stockage local
  Future<void> _loadShares() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('shares');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      _shares.clear();
      decoded.forEach((key, value) {
        _shares[int.parse(key)] = value as int;
      });
      notifyListeners();
    }
  }

  // Sauvegarder les partages dans le stockage local
  Future<void> _saveShares() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
        _shares.map((key, value) => MapEntry(key.toString(), value)));
    await prefs.setString('shares', jsonString);
  }

  // Supprimer tous les partages
  Future<void> clearShares() async {
    _shares.clear();
    await _saveShares();
    notifyListeners();
  }
}

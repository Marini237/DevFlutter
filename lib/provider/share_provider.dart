import 'package:flutter/material.dart';

class ShareProvider extends ChangeNotifier {
  final Map<int, int> _shares = {};

  int getShareCount(int postId) {
    return _shares[postId] ?? 0;
  }

  void addShare(int postId) {
    if (_shares[postId] == null) {
      _shares[postId] = 0;
    }
    _shares[postId] = _shares[postId]! + 1;
    notifyListeners();
  }
}

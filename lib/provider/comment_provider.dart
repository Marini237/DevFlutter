import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comments.dart';

class CommentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer les commentaires racines (pas de parent)
  Stream<List<Comment>> getRootComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .where('parentCommentId', isNull: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final comments = snapshot.docs
          .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      print('Commentaires racines récupérés : $comments');
      return comments;
    });
  }

  // Récupérer les réponses à un commentaire spécifique
  Stream<List<Comment>> getReplies(String postId, String commentId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final replies = snapshot.docs
          .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      print('Réponses récupérées pour le commentaire $commentId : $replies');
      return replies;
    });
  }

  // Ajouter un commentaire
  Future<void> addComment(String postId, Comment comment) async {
    try {
      // Récupérer les données utilisateur depuis Firestore
      final userDoc =
          await _firestore.collection('users').doc(comment.userId).get();

      final userInfo = userDoc.exists
          ? userDoc.data()!
          : {
              'username': 'Anonyme',
              'avatar':
                  'https://images.pexels.com/photos/3373745/pexels-photo-3373745.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
            };

      // Ajouter les données utilisateur au commentaire
      final enrichedComment = Comment(
        id: comment.id,
        postId: comment.postId,
        content: comment.content,
        userId: comment.userId,
        authorName: userInfo['username'] ?? 'Anonyme',
        authorAvatar: userInfo['avatar'] ??
            'https://images.pexels.com/photos/3373745/pexels-photo-3373745.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        timestamp: comment.timestamp,
      );

      // Ajouter le commentaire enrichi dans Firestore
      final commentData = enrichedComment.toJson();
      print('Ajout du commentaire : $commentData');
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(comment.id)
          .set(commentData);

      // Mettre à jour le compteur de commentaires
      await _firestore
          .collection('posts')
          .doc(postId)
          .update({'commentCount': FieldValue.increment(1)});

      notifyListeners();
    } catch (e) {
      print('Erreur lors de l’ajout du commentaire : $e');
    }
  }

  // Ajouter une réponse à un commentaire
  Future<void> addReply(
      String postId, String parentCommentId, Comment reply) async {
    try {
      // Récupérer les données utilisateur depuis Firestore
      final userDoc =
          await _firestore.collection('users').doc(reply.userId).get();

      final userInfo = userDoc.exists
          ? userDoc.data()!
          : {
              'username': 'Anonyme',
              'avatar':
                  'https://images.pexels.com/photos/3373745/pexels-photo-3373745.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
            };

      // Ajouter les données utilisateur à la réponse
      final enrichedReply = Comment(
        id: reply.id,
        postId: reply.postId,
        content: reply.content,
        userId: reply.userId,
        authorName: userInfo['username'] ?? 'Anonyme',
        authorAvatar: userInfo['avatar'] ??
            'https://images.pexels.com/photos/3373745/pexels-photo-3373745.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        timestamp: reply.timestamp,
        parentCommentId: reply.parentCommentId,
      );

      // Ajouter la réponse enrichie dans Firestore
      final replyData = enrichedReply.toJson();
      print('Ajout de la réponse : $replyData');
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(parentCommentId)
          .collection('replies')
          .doc(reply.id)
          .set(replyData);

      notifyListeners();
    } catch (e) {
      print('Erreur lors de l’ajout de la réponse : $e');
    }
  }

  // Liker ou unliker un commentaire
  Future<void> toggleLike(
      String postId, String commentId, String userId) async {
    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    final commentSnapshot = await commentRef.get();

    if (commentSnapshot.exists) {
      final likedBy = List<String>.from(commentSnapshot['likedBy'] ?? []);
      if (likedBy.contains(userId)) {
        // Unlike
        await commentRef.update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likeCount': FieldValue.increment(-1),
        });
        print(
            'Utilisateur $userId a retiré son like du commentaire $commentId');
      } else {
        // Like
        await commentRef.update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likeCount': FieldValue.increment(1),
        });
        print('Utilisateur $userId a liké le commentaire $commentId');
      }
    }
    notifyListeners();
  }

  // Méthode temporaire pour mettre à jour les commentaires existants
  Future<void> updateExistingComments(String postId) async {
    final commentsSnapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    for (final commentDoc in commentsSnapshot.docs) {
      final data = commentDoc.data();
      if (data['authorName'] == null || data['authorAvatar'] == null) {
        final userId = data['userId'];
        if (userId != null) {
          final userDoc =
              await _firestore.collection('users').doc(userId).get();

          final userInfo = userDoc.exists
              ? userDoc.data()!
              : {
                  'username': 'Anonyme',
                  'avatar':
                      'https://images.pexels.com/photos/3373745/pexels-photo-3373745.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
                };

          await commentDoc.reference.update({
            'authorName': userInfo['username'] ?? 'Anonyme',
            'authorAvatar': userInfo['avatar'] ??
                'https://images.pexels.com/photos/3373745/pexels-photo-3373745.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          });
        }
      }
    }
  }
}

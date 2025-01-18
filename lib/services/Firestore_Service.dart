import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer un utilisateur dans Firestore
  Future<void> createUser(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'id': user.uid,
        'email': user.email ?? '',
        'username': user.displayName ?? 'Utilisateur',
        'avatar': user.photoURL ?? 'https://via.placeholder.com/150',
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Récupérer les données utilisateur
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data();
  }

  // Mettre à jour les données utilisateur
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Récupérer les publications
  Stream<List<Map<String, dynamic>>> getPosts() {
    return _firestore.collection('posts').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Ajouter une publication
  Future<void> addPost(Map<String, dynamic> postData) async {
    await _firestore.collection('posts').add(postData);
  }
}

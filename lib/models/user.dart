import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User {
  final String id; // Identifiant unique
  final String username;
  final String avatar;
  final String? email; // Email de l'utilisateur (optionnel)
  final String? bio; // Biographie de l'utilisateur (optionnel)
  final String role; // Rôle de l'utilisateur (ex. : "admin", "user")
  final int? postCount; // Nombre de posts de l'utilisateur (optionnel)
  final Map<String, dynamic>? preferences; // Préférences utilisateur

  const User({
    required this.id,
    required this.username,
    required this.avatar,
    this.email,
    this.bio,
    this.role = 'user',
    this.postCount,
    this.preferences,
  });

  // Convertir un utilisateur en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'email': email,
      'bio': bio,
      'role': role,
      'postCount': postCount,
      'preferences': preferences,
    };
  }

  // Créer un utilisateur à partir de JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? 'https://via.placeholder.com/150',
      email: json['email'],
      bio: json['bio'],
      role: json['role'] ?? 'user',
      postCount: json['postCount'],
      preferences: json['preferences'] != null
          ? Map<String, dynamic>.from(json['preferences'])
          : null,
    );
  }

  // Créer un utilisateur à partir d'un utilisateur Firebase
  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      username: firebaseUser.displayName ?? 'Utilisateur Anonyme',
      avatar: firebaseUser.photoURL ??
          'https://cdn.pixabay.com/photo/2017/06/13/12/54/profile-2398783_1280.png',
      email: firebaseUser.email,
      bio: null, // Firebase Auth ne fournit pas de bio
    );
  }

  // Méthode pour mettre à jour les champs optionnels
  User copyWith({
    String? username,
    String? avatar,
    String? email,
    String? bio,
    String? role,
    int? postCount,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      postCount: postCount ?? this.postCount,
      preferences: preferences ?? this.preferences,
    );
  }

  // Validation des champs critiques
  void validate() {
    if (id.isEmpty) {
      throw ArgumentError('L\'id de l\'utilisateur ne peut pas être vide.');
    }
    if (username.isEmpty) {
      throw ArgumentError('Le nom d\'utilisateur ne peut pas être vide.');
    }
    if (avatar.isEmpty || (Uri.tryParse(avatar)?.isAbsolute != true)) {
      throw ArgumentError('L\'avatar doit être une URL valide.');
    }
  }

  // Vérifier si l'utilisateur est un administrateur
  bool isAdmin() {
    return role == 'admin';
  }

  // Vérifier si le profil est complet
  bool isCompleteProfile() {
    return email != null && bio != null;
  }
}

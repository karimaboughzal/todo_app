import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  // Obtenir l'utilisateur actuel
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Obtenir tous les utilisateurs enregistrés
  Future<List<Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final List<dynamic> decoded = json.decode(usersJson);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Sauvegarder les utilisateurs
  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, json.encode(users));
  }

  // Inscription avec email et mot de passe
  Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      final users = await _getUsers();
      
      // Vérifier si l'email existe déjà
      final existingUser = users.firstWhere(
        (user) => user['email'] == email,
        orElse: () => {},
      );

      if (existingUser.isNotEmpty) {
        return {
          'success': false,
          'message': 'Un compte existe déjà avec cet email',
        };
      }

      // Créer le nouvel utilisateur
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'password': password, // Dans un vrai app, on devrait hasher le mot de passe
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      };

      users.add(newUser);
      await _saveUsers(users);

      // Connecter automatiquement l'utilisateur
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode({
        'id': newUser['id'],
        'email': newUser['email'],
        'name': newUser['name'],
      }));

      return {
        'success': true,
        'message': 'Inscription réussie !',
        'user': newUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue',
      };
    }
  }

  // Connexion avec email et mot de passe
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final users = await _getUsers();
      
      // Chercher l'utilisateur
      final user = users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        return {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        };
      }

      // Sauvegarder l'utilisateur connecté
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode({
        'id': user['id'],
        'email': user['email'],
        'name': user['name'],
      }));

      return {
        'success': true,
        'message': 'Connexion réussie !',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue',
      };
    }
  }

  // Réinitialiser le mot de passe
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final users = await _getUsers();
      
      // Vérifier si l'email existe
      final userIndex = users.indexWhere((user) => user['email'] == email);

      if (userIndex == -1) {
        return {
          'success': false,
          'message': 'Aucun compte trouvé avec cet email',
        };
      }

      // Dans une vraie app, on enverrait un email
      // Ici, on génère juste un nouveau mot de passe temporaire
      final newPassword = 'temp${DateTime.now().millisecondsSinceEpoch}';
      users[userIndex]['password'] = newPassword;
      await _saveUsers(users);

      // En production, on enverrait l'email ici
      print('Nouveau mot de passe temporaire : $newPassword');

      return {
        'success': true,
        'message': 'Email de réinitialisation envoyé ! (Vérifiez la console pour le mot de passe temporaire)',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue',
      };
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Supprimer le compte
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Aucun utilisateur connecté',
        };
      }

      final users = await _getUsers();
      users.removeWhere((user) => user['id'] == currentUser['id']);
      await _saveUsers(users);
      await signOut();

      return {
        'success': true,
        'message': 'Compte supprimé avec succès',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue',
      };
    }
  }
}
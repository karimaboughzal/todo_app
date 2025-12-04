import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream pour vérifier l'état de connexion
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Inscription avec email et mot de passe
  Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Créer l'utilisateur
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le nom d'affichage
      await userCredential.user?.updateDisplayName(name);

      return {
        'success': true,
        'message': 'Inscription réussie !',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Le mot de passe est trop faible';
          break;
        case 'email-already-in-use':
          message = 'Un compte existe déjà avec cet email';
          break;
        case 'invalid-email':
          message = 'L\'email est invalide';
          break;
        default:
          message = 'Une erreur est survenue : ${e.message}';
      }
      return {
        'success': false,
        'message': message,
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
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'success': true,
        'message': 'Connexion réussie !',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun compte trouvé avec cet email';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          message = 'L\'email est invalide';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé';
          break;
        default:
          message = 'Une erreur est survenue : ${e.message}';
      }
      return {
        'success': false,
        'message': message,
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
      await _auth.sendPasswordResetEmail(email: email);

      return {
        'success': true,
        'message': 'Email de réinitialisation envoyé !',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun compte trouvé avec cet email';
          break;
        case 'invalid-email':
          message = 'L\'email est invalide';
          break;
        default:
          message = 'Une erreur est survenue : ${e.message}';
      }
      return {
        'success': false,
        'message': message,
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
    await _auth.signOut();
  }

  // Supprimer le compte
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      return {
        'success': true,
        'message': 'Compte supprimé avec succès',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'requires-recent-login':
          message = 'Veuillez vous reconnecter pour supprimer votre compte';
          break;
        default:
          message = 'Une erreur est survenue : ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue',
      };
    }
  }
}
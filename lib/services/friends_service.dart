import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/friend.dart';

class FriendsService {
  static const String _friendsKey = 'friends';

  // Charger les amis
  Future<List<Friend>> loadFriends() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString(_friendsKey);
      
      if (friendsJson != null) {
        final List<dynamic> decoded = json.decode(friendsJson);
        return decoded.map((item) => Friend.fromJson(item)).toList();
      }
      
      return [];
    } catch (e) {
      print('Erreur lors du chargement des amis: $e');
      return [];
    }
  }

  // Sauvegarder les amis
  Future<bool> saveFriends(List<Friend> friends) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = json.encode(
        friends.map((friend) => friend.toJson()).toList(),
      );
      return await prefs.setString(_friendsKey, friendsJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde des amis: $e');
      return false;
    }
  }

  // Ajouter un ami
  Future<Map<String, dynamic>> addFriend({
    required String name,
    required String email,
    String? phone,
    required String addedBy,
  }) async {
    try {
      final friends = await loadFriends();
      
      // Vérifier si l'ami existe déjà
      final existingFriend = friends.where((f) => 
        f.email.toLowerCase() == email.toLowerCase() && f.addedBy == addedBy
      ).firstOrNull;

      if (existingFriend != null) {
        return {
          'success': false,
          'message': 'Cet ami est déjà dans votre liste',
        };
      }

      // Créer le nouvel ami
      final newFriend = Friend(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        addedBy: addedBy,
        addedAt: DateTime.now(),
        isPending: true,
      );

      friends.add(newFriend);
      await saveFriends(friends);

      return {
        'success': true,
        'message': 'Ami ajouté avec succès',
        'friend': newFriend,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'ajout de l\'ami',
      };
    }
  }

  // Supprimer un ami
  Future<bool> deleteFriend(String friendId, String userId) async {
    try {
      final friends = await loadFriends();
      friends.removeWhere((f) => f.id == friendId && f.addedBy == userId);
      return await saveFriends(friends);
    } catch (e) {
      return false;
    }
  }

  // Obtenir les amis d'un utilisateur
  Future<List<Friend>> getFriendsForUser(String userId) async {
    final allFriends = await loadFriends();
    return allFriends.where((f) => f.addedBy == userId).toList();
  }

  // Accepter une invitation
  Future<bool> acceptInvitation(String friendId) async {
    try {
      final friends = await loadFriends();
      final friendIndex = friends.indexWhere((f) => f.id == friendId);
      
      if (friendIndex != -1) {
        friends[friendIndex].isPending = false;
        return await saveFriends(friends);
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}
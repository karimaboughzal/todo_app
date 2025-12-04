import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';

  // Charger les tâches depuis le stockage local
  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      
      if (tasksJson != null) {
        final List<dynamic> decoded = json.decode(tasksJson);
        return decoded.map((item) => Task.fromJson(item)).toList();
      }
      
      return [];
    } catch (e) {
      print('Erreur lors du chargement des tâches: $e');
      return [];
    }
  }

  // Sauvegarder les tâches dans le stockage local
  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = json.encode(
        tasks.map((task) => task.toJson()).toList(),
      );
      return await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde des tâches: $e');
      return false;
    }
  }

  // Effacer toutes les tâches
  Future<bool> clearAllTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tasksKey);
    } catch (e) {
      print('Erreur lors de la suppression des tâches: $e');
      return false;
    }
  }
}
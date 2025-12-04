import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_dialog.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final StorageService _storageService = StorageService();
  List<Task> _tasks = [];
  bool _showCompletedOnly = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Charger les tâches
  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    
    final tasks = await _storageService.loadTasks();
    
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  // Sauvegarder les tâches
  Future<void> _saveTasks() async {
    await _storageService.saveTasks(_tasks);
  }

  // Ajouter une tâche
  void _addTask(String title, String description) {
    setState(() {
      _tasks.add(Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        createdAt: DateTime.now(),
      ));
    });
    _saveTasks();
  }

  // Basculer l'état de complétion d'une tâche
  void _toggleTaskCompletion(String id) {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.isCompleted = !task.isCompleted;
    });
    _saveTasks();
  }

  // Supprimer une tâche
  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
    _saveTasks();
  }

  // Obtenir les tâches filtrées
  List<Task> _getFilteredTasks() {
    if (_showCompletedOnly) {
      return _tasks.where((task) => task.isCompleted).toList();
    }
    return _tasks;
  }

  // Afficher le dialog d'ajout de tâche
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onAddTask: _addTask,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();
    final completedCount = _tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tâches'),
        actions: [
          IconButton(
            icon: Icon(
              _showCompletedOnly ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            onPressed: () {
              setState(() {
                _showCompletedOnly = !_showCompletedOnly;
              });
            },
            tooltip: _showCompletedOnly ? 'Afficher toutes' : 'Afficher complétées',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsSection(completedCount),
                Expanded(
                  child: filteredTasks.isEmpty
                      ? _buildEmptyState()
                      : _buildTaskList(filteredTasks),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle tâche'),
      ),
    );
  }

  // Widget pour la section des statistiques
  Widget _buildStatsSection(int completedCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total', _tasks.length.toString(), Colors.blue),
          _buildStatCard('Complétées', completedCount.toString(), Colors.green),
          _buildStatCard(
            'En cours',
            (_tasks.length - completedCount).toString(),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  // Widget pour une carte de statistique
  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // Widget pour l'état vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _showCompletedOnly
                ? 'Aucune tâche complétée'
                : 'Aucune tâche pour le moment',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour ajouter une tâche',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // Widget pour la liste des tâches
  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          task: task,
          onToggle: _toggleTaskCompletion,
          onDelete: _deleteTask,
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/friend.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/friends_service.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_dialog.dart';
import 'statistics_page.dart';
import 'completed_tasks_page.dart';
import 'settings_page.dart';
import 'login_page.dart';
import 'calendar_page.dart';
import 'friends_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  final FriendsService _friendsService = FriendsService();
  List<Task> _tasks = [];
  List<Friend> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Charger les tâches et les amis
  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    
    final tasks = await _storageService.loadTasks();
    final user = await _authService.getCurrentUser();
    
    if (user != null) {
      final friends = await _friendsService.getFriendsForUser(user['id']);
      setState(() {
        _tasks = tasks;
        _friends = friends;
        _isLoading = false;
      });
    } else {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  // Sauvegarder les tâches
  Future<void> _saveTasks() async {
    await _storageService.saveTasks(_tasks);
  }

  // Ajouter une tâche
  void _addTask(String title, String description, DateTime? dueDate, String? assignedTo, String status) async {
    final user = await _authService.getCurrentUser();
    
    setState(() {
      _tasks.add(Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        assignedTo: assignedTo,
        createdBy: user?['id'] ?? '',
        status: status,
      ));
    });
    _saveTasks();
  }

  // Basculer l'état de complétion d'une tâche
  void _toggleTaskCompletion(String id) {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.isCompleted = !task.isCompleted;
      if (task.isCompleted) {
        task.status = 'completed';
      } else {
        task.status = task.status == 'completed' ? 'in_progress' : task.status;
      }
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

  // Supprimer toutes les tâches
  void _clearAllTasks() {
    setState(() {
      _tasks.clear();
    });
    _saveTasks();
  }

  // Obtenir les tâches en cours
  List<Task> _getPendingTasks() {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  // Afficher le dialog d'ajout de tâche
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onAddTask: _addTask,
        friends: _friends,
      ),
    );
  }

  // Afficher le dialog À propos
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestionnaire de Tâches',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('Version: 2.0.0'),
            SizedBox(height: 8),
            Text('Développé avec Flutter & Dart'),
            SizedBox(height: 8),
            Text('Application collaborative de gestion de tâches.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Construire le Drawer (menu latéral)
  Widget _buildDrawer() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _authService.getCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?['name'] ?? 'Utilisateur',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?['email'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Accueil'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Calendrier'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarPage(
                        tasks: _tasks,
                        onToggle: _toggleTaskCompletion,
                        onDelete: _deleteTask,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Mes Amis'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FriendsPage(),
                    ),
                  ).then((_) => _loadTasks());
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Tâches complétées'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompletedTasksPage(
                        tasks: _tasks,
                        onToggle: _toggleTaskCompletion,
                        onDelete: _deleteTask,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Statistiques'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatisticsPage(tasks: _tasks),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Paramètres'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(
                        onClearAll: _clearAllTasks,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('À propos'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = _getPendingTasks();
    final completedCount = _tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tâches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(
                    tasks: _tasks,
                    onToggle: _toggleTaskCompletion,
                    onDelete: _deleteTask,
                  ),
                ),
              );
            },
            tooltip: 'Calendrier',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsSection(completedCount),
                Expanded(
                  child: pendingTasks.isEmpty
                      ? _buildEmptyState()
                      : _buildTaskList(pendingTasks),
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
            'Aucune tâche en cours',
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
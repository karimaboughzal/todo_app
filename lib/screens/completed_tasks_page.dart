import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

class CompletedTasksPage extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onToggle;
  final Function(String) onDelete;

  const CompletedTasksPage({
    Key? key,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tâches Complétées'),
        actions: [
          if (completedTasks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(context),
              tooltip: 'Tout supprimer',
            ),
        ],
      ),
      body: completedTasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune tâche complétée',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complétez vos tâches pour les voir ici',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.celebration, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${completedTasks.length} tâche${completedTasks.length > 1 ? 's' : ''} terminée${completedTasks.length > 1 ? 's' : ''} !',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: completedTasks.length,
                    itemBuilder: (context, index) {
                      final task = completedTasks[index];
                      return TaskItem(
                        task: task,
                        onToggle: onToggle,
                        onDelete: onDelete,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer toutes les tâches complétées'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer toutes les tâches complétées ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final completedTasks = tasks.where((task) => task.isCompleted).toList();
              for (var task in completedTasks) {
                onDelete(task.id);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les tâches complétées ont été supprimées'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Supprimer tout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
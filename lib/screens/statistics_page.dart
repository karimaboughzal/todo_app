import 'package:flutter/material.dart';
import '../models/task.dart';

class StatisticsPage extends StatelessWidget {
  final List<Task> tasks;

  const StatisticsPage({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;
    final completionRate = totalTasks > 0 
        ? (completedTasks / totalTasks * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: totalTasks == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune statistique disponible',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des tâches pour voir vos statistiques',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Carte de progression
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Taux de complétion',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: CircularProgressIndicator(
                                  value: completedTasks / totalTasks,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    completedTasks / totalTasks > 0.7
                                        ? Colors.green
                                        : completedTasks / totalTasks > 0.4
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ),
                              Text(
                                '$completionRate%',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Statistiques détaillées
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          totalTasks.toString(),
                          Icons.list_alt,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Complétées',
                          completedTasks.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'En cours',
                          pendingTasks.toString(),
                          Icons.pending,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Aujourd\'hui',
                          _getTodayTasksCount().toString(),
                          Icons.today,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Analyse
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.insights, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'Analyse',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildAnalysisItem(
                            'Productivité',
                            _getProductivityMessage(completedTasks, totalTasks),
                            _getProductivityIcon(completedTasks, totalTasks),
                          ),
                          const Divider(),
                          _buildAnalysisItem(
                            'Progression',
                            _getProgressMessage(completedTasks, totalTasks),
                            Icons.trending_up,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
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
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getTodayTasksCount() {
    final today = DateTime.now();
    return tasks.where((task) {
      return task.createdAt.year == today.year &&
          task.createdAt.month == today.month &&
          task.createdAt.day == today.day;
    }).length;
  }

  String _getProductivityMessage(int completed, int total) {
    final rate = total > 0 ? completed / total : 0;
    if (rate >= 0.8) return 'Excellente productivité ! Continuez ainsi.';
    if (rate >= 0.5) return 'Bonne progression, vous êtes sur la bonne voie.';
    return 'Concentrez-vous sur vos tâches en cours.';
  }

  IconData _getProductivityIcon(int completed, int total) {
    final rate = total > 0 ? completed / total : 0;
    if (rate >= 0.8) return Icons.emoji_events;
    if (rate >= 0.5) return Icons.thumb_up;
    return Icons.info_outline;
  }

  String _getProgressMessage(int completed, int total) {
    if (completed == total && total > 0) {
      return 'Toutes vos tâches sont terminées ! Bravo !';
    }
    final remaining = total - completed;
    return 'Il vous reste $remaining tâche${remaining > 1 ? 's' : ''} à accomplir.';
  }
}
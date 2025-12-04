import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsPage extends StatelessWidget {
  final Function() onClearAll;

  const SettingsPage({Key? key, required this.onClearAll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildSectionHeader('Général'),
          _buildSettingTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Recevoir des rappels pour vos tâches',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir !'),
                  ),
                );
              },
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.dark_mode,
            title: 'Mode sombre',
            subtitle: 'Activer le thème sombre',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir !'),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          _buildSectionHeader('Données'),
          _buildSettingTile(
            context,
            icon: Icons.delete_forever,
            title: 'Supprimer toutes les tâches',
            subtitle: 'Effacer toutes vos données',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearAllDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: Icons.backup,
            title: 'Sauvegarder les données',
            subtitle: 'Exporter vos tâches',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir !'),
                ),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('À propos'),
          _buildSettingTile(
            context,
            icon: Icons.info,
            title: 'Version',
            subtitle: '1.0.0',
            trailing: const SizedBox(),
          ),
          _buildSettingTile(
            context,
            icon: Icons.person,
            title: 'Développeur',
            subtitle: 'Application de gestion de tâches',
            trailing: const SizedBox(),
          ),
          _buildSettingTile(
            context,
            icon: Icons.code,
            title: 'Technologies',
            subtitle: 'Flutter & Dart',
            trailing: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue.shade700),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer toutes les tâches'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer TOUTES vos tâches ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              onClearAll();
              Navigator.pop(context);
              Navigator.pop(context); // Retour à l'écran principal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les tâches ont été supprimées'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Supprimer tout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
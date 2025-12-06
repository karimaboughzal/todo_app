import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/friend.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(String title, String description, DateTime? dueDate, String? assignedTo, String status) onAddTask;
  final List<Friend>? friends;

  const AddTaskDialog({
    Key? key,
    required this.onAddTask,
    this.friends,
  }) : super(key: key);

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedFriendId;
  String _selectedStatus = 'todo';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      widget.onAddTask(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        _selectedDate,
        _selectedFriendId,
        _selectedStatus,
      );
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle tâche'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              
              // Date d'échéance
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date d\'échéance',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Sélectionner une date'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Statut
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'todo',
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.grey, size: 12),
                        SizedBox(width: 8),
                        Text('À faire'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'in_progress',
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.orange, size: 12),
                        SizedBox(width: 8),
                        Text('En cours'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              
              // Assigner à un ami
              if (widget.friends != null && widget.friends!.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedFriendId,
                  decoration: const InputDecoration(
                    labelText: 'Assigner à',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  hint: const Text('Choisir un ami (optionnel)'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Moi-même'),
                    ),
                    ...widget.friends!.map((friend) {
                      return DropdownMenuItem<String>(
                        value: friend.id,
                        child: Text(friend.name),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFriendId = value;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submitTask,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
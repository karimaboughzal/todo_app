class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate; // Date d'échéance
  String? assignedTo; // ID de l'ami assigné
  String createdBy; // ID du créateur
  String status; // 'todo', 'in_progress', 'completed'

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.assignedTo,
    required this.createdBy,
    this.status = 'todo',
  });

  // Convertir un objet Task en JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'assignedTo': assignedTo,
        'createdBy': createdBy,
        'status': status,
      };

  // Créer un objet Task à partir de JSON
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        assignedTo: json['assignedTo'],
        createdBy: json['createdBy'] ?? '',
        status: json['status'] ?? 'todo',
      );
}
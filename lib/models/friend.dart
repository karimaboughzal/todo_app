class Friend {
  String id;
  String name;
  String email;
  String? phone;
  String addedBy; // ID de l'utilisateur qui a ajouté l'ami
  DateTime addedAt;
  bool isPending; // En attente d'acceptation
  String? userId; // ID de l'utilisateur si inscrit

  Friend({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.addedBy,
    required this.addedAt,
    this.isPending = true,
    this.userId,
  });

  // Convertir en JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'addedBy': addedBy,
        'addedAt': addedAt.toIso8601String(),
        'isPending': isPending,
        'userId': userId,
      };

  // Créer à partir de JSON
  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        addedBy: json['addedBy'],
        addedAt: DateTime.parse(json['addedAt']),
        isPending: json['isPending'] ?? true,
        userId: json['userId'],
      );
}
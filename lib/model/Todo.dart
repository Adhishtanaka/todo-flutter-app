class Todo {
  final String id;
  final String title;
  final String? description;
  final DateTime? deadline;
  final DateTime? createdAt;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.deadline,
    this.createdAt,
    this.completed = false,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description != null?
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'completed': completed,
    };
  }
}
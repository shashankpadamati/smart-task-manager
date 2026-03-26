import 'sub_task.dart';

class Task {
  final int? id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime? createdAt;
  final String priority;
  final DateTime? dueDate;
  final List<SubTask> subtasks;
  final List<String> tags;

  Task({
    this.id,
    required this.title,
    this.description,
    this.completed = false,
    this.createdAt,
    this.priority = 'MEDIUM',
    this.dueDate,
    this.subtasks = const [],
    this.tags = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      priority: json['priority'] ?? 'MEDIUM',
      dueDate:
          json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      subtasks: json['subtasks'] != null
          ? (json['subtasks'] as List)
              .map((s) => SubTask.fromJson(s))
              .toList()
          : [],
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'tags': tags,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
    String? priority,
    DateTime? dueDate,
    List<SubTask>? subtasks,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
    );
  }
}

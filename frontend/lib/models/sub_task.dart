class SubTask {
  final int? id;
  final String title;
  final bool completed;

  SubTask({this.id, required this.title, this.completed = false});

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'completed': completed,
    };
  }

  SubTask copyWith({int? id, String? title, bool? completed}) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

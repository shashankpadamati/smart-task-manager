import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/sub_task.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class ApiService {
  String? _token;
  void Function()? onUnauthorized;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ──────────────────────────────────────────────

  Future<AuthUser> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.authLogin),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return AuthUser.fromJson(jsonDecode(response.body));
    }
    throw _parseError(response);
  }

  Future<AuthUser> signup(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.authSignup),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return AuthUser.fromJson(jsonDecode(response.body));
    }
    throw _parseError(response);
  }

  // ── Tasks ─────────────────────────────────────────────

  Future<List<Task>> getTasks({
    bool? completed,
    String? priority,
    String? tag,
    String? search,
    String sortBy = 'newest',
  }) async {
    final params = <String, String>{
      'sortBy': sortBy,
    };
    if (completed != null) params['completed'] = completed.toString();
    if (priority != null) params['priority'] = priority;
    if (tag != null && tag.isNotEmpty) params['tag'] = tag;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse(ApiConstants.tasks).replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    }
    throw _parseError(response);
  }

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse(ApiConstants.tasks),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    }
    throw _parseError(response);
  }

  Future<Task> getTaskById(int id) async {
    final response = await http.get(
      Uri.parse(ApiConstants.taskById(id)),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    }
    throw _parseError(response);
  }

  Future<Task> updateTask(int id, Task task) async {
    final response = await http.put(
      Uri.parse(ApiConstants.taskById(id)),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    }
    throw _parseError(response);
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse(ApiConstants.taskById(id)),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
  }

  Future<Task> toggleComplete(int id) async {
    final response = await http.patch(
      Uri.parse(ApiConstants.taskComplete(id)),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    }
    throw _parseError(response);
  }

  // ── SubTasks ──────────────────────────────────────────

  Future<SubTask> createSubTask(int taskId, String title) async {
    final response = await http.post(
      Uri.parse(ApiConstants.subtasks(taskId)),
      headers: _headers,
      body: jsonEncode({'title': title}),
    );
    if (response.statusCode == 200) {
      return SubTask.fromJson(jsonDecode(response.body));
    }
    throw _parseError(response);
  }

  Future<void> deleteSubTask(int taskId, int subId) async {
    final response = await http.delete(
      Uri.parse(ApiConstants.subtaskById(taskId, subId)),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
  }

  Future<SubTask> toggleSubTaskComplete(int taskId, int subId) async {
    final response = await http.patch(
      Uri.parse(ApiConstants.subtaskComplete(taskId, subId)),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return SubTask.fromJson(jsonDecode(response.body));
    }
    throw _parseError(response);
  }

  // ── Tags ──────────────────────────────────────────────

  Future<List<String>> getTags() async {
    final response = await http.get(
      Uri.parse(ApiConstants.tags),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    throw _parseError(response);
  }

  // ── Helpers ───────────────────────────────────────────

  String _parseError(http.Response response) {
    if (response.statusCode == 401) {
      onUnauthorized?.call();
    }
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? body['error'] ?? 'Request failed (${response.statusCode})';
    } catch (_) {
      return 'Request failed (${response.statusCode})';
    }
  }
}

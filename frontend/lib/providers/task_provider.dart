import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _api;

  List<Task> _tasks = [];
  List<String> _allTags = [];
  bool _loading = false;
  String? _error;

  // Filters & sorting
  String _sortBy = 'newest';
  bool? _filterCompleted;
  String? _filterPriority;
  String? _filterTag;
  String _searchQuery = '';

  TaskProvider(this._api);

  // ── Getters ───────────────────────────────────────────
  List<Task> get tasks => _tasks;
  List<String> get allTags => _allTags;
  bool get loading => _loading;
  String? get error => _error;
  String get sortBy => _sortBy;
  bool? get filterCompleted => _filterCompleted;
  String? get filterPriority => _filterPriority;
  String? get filterTag => _filterTag;
  String get searchQuery => _searchQuery;

  // ── Load Tasks ────────────────────────────────────────
  Future<void> loadTasks() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await _api.getTasks(
        completed: _filterCompleted,
        priority: _filterPriority,
        tag: _filterTag,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
      );
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadTags() async {
    try {
      _allTags = await _api.getTags();
      notifyListeners();
    } catch (_) {}
  }

  // ── Task CRUD ─────────────────────────────────────────
  Future<bool> createTask(Task task) async {
    try {
      await _api.createTask(task);
      await loadTasks();
      await loadTags();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(int id, Task task) async {
    try {
      await _api.updateTask(id, task);
      await loadTasks();
      await loadTags();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _api.deleteTask(id);
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleComplete(int id) async {
    try {
      await _api.toggleComplete(id);
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── SubTask Operations ────────────────────────────────
  Future<bool> addSubTask(int taskId, String title) async {
    try {
      await _api.createSubTask(taskId, title);
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubTask(int taskId, int subId) async {
    try {
      await _api.deleteSubTask(taskId, subId);
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleSubTaskComplete(int taskId, int subId) async {
    try {
      await _api.toggleSubTaskComplete(taskId, subId);
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Filters & Sort ────────────────────────────────────
  void setSortBy(String sort) {
    _sortBy = sort;
    loadTasks();
  }

  void setFilterCompleted(bool? value) {
    _filterCompleted = value;
    loadTasks();
  }

  void setFilterPriority(String? value) {
    _filterPriority = value;
    loadTasks();
  }

  void setFilterTag(String? value) {
    _filterTag = value;
    loadTasks();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadTasks();
  }

  void clearFilters() {
    _sortBy = 'newest';
    _filterCompleted = null;
    _filterPriority = null;
    _filterTag = null;
    _searchQuery = '';
    loadTasks();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

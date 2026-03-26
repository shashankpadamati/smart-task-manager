import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api;
  AuthUser? _user;
  bool _loading = false;
  String? _error;

  AuthProvider(this._api) {
    _api.onUnauthorized = logout;
    _loadSavedToken();
  }

  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;
  String? get error => _error;
  String? get token => _user?.token;

  Future<void> _loadSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('jwt_token');
    final savedId = prefs.getInt('user_id');
    final savedName = prefs.getString('username');
    if (savedToken != null && savedId != null && savedName != null) {
      _user = AuthUser(token: savedToken, id: savedId, username: savedName);
      _api.setToken(savedToken);
      notifyListeners();
    }
  }

  Future<void> _saveToken(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', user.token);
    await prefs.setInt('user_id', user.id);
    await prefs.setString('username', user.username);
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _api.login(email, password);
      _api.setToken(_user!.token);
      await _saveToken(_user!);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String username, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _api.signup(username, email, password);
      _api.setToken(_user!.token);
      await _saveToken(_user!);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

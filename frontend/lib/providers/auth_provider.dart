
import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token;
  String? _role;
  User? _user;

  String? get token => _token;
  String? get role => _role;
  User? get user => _user;

  bool get isAuthenticated => _token != null;

  Future<void> fetchUser() async {
    _user = await _apiService.getUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final userData = await _apiService.login(email, password);
    if (userData != null) {
      _user = User.fromJson(userData['user']);
      _token = userData['token'];
      _role = _user?.role;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('role', _role!);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return false;
    }
    _token = prefs.getString('token');
    if (_token != null) {
      _role = prefs.getString('role');
      await fetchUser();
    }
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    _user = null; // Clear user object on logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> toggleFavorite(String jobId) async {
    final updatedUser = await _apiService.toggleFavorite(jobId);
    if (updatedUser != null) {
      _user = updatedUser;
      notifyListeners();
    }
  }
}

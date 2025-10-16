import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await _apiService.getAllUsers();
    } catch (e) {
      // In a real app, you might want to handle this error more gracefully
      print('Error fetching users: $e');
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.deleteUser(userId);
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow; // Re-throw to be caught in the UI
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      final updatedUser = await _apiService.updateUser(userId, {'role': newRole});
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating user role: $e');
      rethrow; // Re-throw to be caught in the UI
    }
  }
}
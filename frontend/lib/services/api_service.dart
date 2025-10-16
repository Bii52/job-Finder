import 'dart:convert';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/job.dart';
import 'package:frontend/models/message.dart';
import 'package:frontend/screens/conversation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // !!! QUAN TRỌNG: Hãy thay đổi địa chỉ IP này thành địa chỉ IP của máy bạn
  static const String _baseUrl = 'http://10.12.189.87:3000/api';

  // Lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Tạo headers cho request, đính kèm token nếu có
  Future<Map<String, String>> _getHeaders({bool noCache = false}) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (noCache) {
      headers['Cache-Control'] = 'no-cache';
    }
    return headers;
  }

  // Phương thức GET helper
  Future<dynamic> _get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Phương thức POST helper
  Future<dynamic> _post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // Phương thức PUT helper
  Future<dynamic> _put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // Phương thức DELETE helper
  Future<dynamic> _delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Xử lý response chung từ server
  dynamic _handleResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else if (response.statusCode == 304) {
      // Not Modified: Dữ liệu không thay đổi. Trả về null để provider biết không cần cập nhật.
      return null;
    } else {
      throw Exception(responseBody['message'] ?? 'An error occurred');
    }
  }

  // --- Các phương thức cho User & Auth ---

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _post('/users/login', {
        'email': email,
        'password': password,
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['token']);
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<User?> register(String name, String email, String password, String role) async {
    try {
      final response = await _post('/users/register', {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      return User.fromJson(response['user']);
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  Future<User> getUser() async {
    final response = await _get('/users/me');
    return User.fromJson(response);
  }

  Future<User> toggleFavorite(String jobId) async {
    final response = await _post('/users/favorites/$jobId', {});
    return User.fromJson(response);
  }

  // --- Các phương thức cho Admin (ĐÃ THÊM) ---

  Future<List<User>> getAllUsers() async {
    final response = await _get('/users');
    final List<dynamic> usersJson = response;
    return usersJson.map((json) => User.fromJson(json)).toList();
  }

  Future<User> updateUser(String userId, Map<String, dynamic> data) async {
    final response = await _put('/users/$userId', data);
    return User.fromJson(response);
  }

  Future<void> deleteUser(String userId) async {
    await _delete('/users/$userId');
  }

  // --- Các phương thức cho Job ---

  Future<List<Job>?> getJobs() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/jobs'),
      headers: await _getHeaders(noCache: true),
    );
    // Xử lý response đặc biệt cho getJobs để phân biệt 304
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Job.fromJson(json)).toList();
    } else if (response.statusCode == 304) {
      return null; // Trả về null nếu không có gì thay đổi
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load jobs');
    }
  }

  Future<Job> createJob(String title, String description, String company, String location, int? salary, List<String> skills) async {
    final response = await _post('/jobs', {
      'title': title,
      'description': description,
      'company': company,
      'location': location,
      'salary': salary,
      'skills': skills,
    });
    return Job.fromJson(response);
  }

  Future<Job> updateJob(String id, String title, String description, String company, String location, int? salary, List<String> skills) async {
    final response = await _put('/jobs/$id', {
      'title': title,
      'description': description,
      'company': company,
      'location': location,
      'salary': salary,
      'skills': skills,
    });
    return Job.fromJson(response);
  }

  Future<void> deleteJob(String id) async {
    await _delete('/jobs/$id');
  }

  Future<void> applyForJob(String jobId) async {
    await _post('/jobs/$jobId/apply', {});
  }

  Future<List<dynamic>> getApplicants(String jobId) async {
    final response = await _get('/jobs/$jobId/applicants');
    return response as List<dynamic>;
  }

  // --- Các phương thức cho Chat ---

  Future<List<dynamic>> getMessages(String conversationId) async {
    return await _get('/chat/$conversationId');
  }

  Future<Message> addMessage(String conversationId, String text) async {
    final response = await _post('/chat/message', {
      'conversationId': conversationId,
      'text': text,
    });
    return Message.fromJson(response);
  }

  Future<Conversation?> createConversation(String recipientId) async {
    try {
      final response = await _post('/chat', {'recipientId': recipientId});
      return Conversation.fromJson(response);
    } catch (e) {
      print('Create conversation error: $e');
      return null;
    }
  }

  Future<void> inviteToApply(String userId, String jobId) async {
    // Endpoint này cần được tạo ở backend
    await _post('/users/$userId/invite', {
      'jobId': jobId,
    });
  }
}

import 'dart:convert';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/message.dart';
import 'package:frontend/screens/conversation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl = 'http://192.168.1.11:3000';

  Future<Map<String, dynamic>?> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/api/users/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'email': email, 'password': password}),
  );

  print('Login status: ${response.statusCode}');
  print('Login body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final token = data['token'];

    if (token == null) {
      print('⚠️ Không nhận được token từ server!');
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('✅ Token đã lưu: $token');
    return data;
  } else {
    print('❌ Login failed: ${response.body}');
    return null;
  }
}


  Future<User?> register(
    String username,
    String email,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/me'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<User?> toggleFavorite(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/favorites/$jobId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // Handle error
      return null;
    }
  }

  Future<List<dynamic>> getMessages(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/chat/$conversationId'),
      headers: {'Authorization': 'Bearer $token'}, // Thống nhất cách viết hoa
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<Message> addMessage(String conversationId, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat/message'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Thống nhất cách viết hoa
      },
      body: jsonEncode({'conversationId': conversationId, 'text': text}),
    );

    if (response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<Conversation?> createConversation(String recipientId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'recipientId': recipientId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Conversation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create conversation');
    }
  }
}

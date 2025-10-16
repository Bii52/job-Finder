import 'dart:convert';
import 'package:frontend/models/job.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JobService {
  final String _baseUrl = 'http://10.12.189.87:3000';

  Future<List<Job>> getJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/jobs'),
      headers: {
        // Thêm header này để đảm bảo dữ liệu luôn được lấy mới từ server khi refresh
        'Cache-Control': 'no-cache',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Job.fromJson(json)).toList();
    } else if (response.statusCode == 304) {
      // Not Modified - Dữ liệu không thay đổi, không cần làm gì, trả về danh sách rỗng để provider không báo lỗi
      return [];
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  Future<Job> createJob(String title, String description, String company, String location, int? salary, List<String> skills) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/jobs'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'company': company,
        'location': location,
        'salary': salary,
        'skills': skills,
      }),
    );

    if (response.statusCode == 201) {
      return Job.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create job');
    }
  }

    Future<Job> updateJob(String id, String title, String description, String company, String location, int? salary, List<String> skills) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/api/jobs/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'company': company,
        'location': location,
        'salary': salary,
        'skills': skills,
      }),
    );

    if (response.statusCode == 200) {
      return Job.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update job');
    }
  }

  Future<void> deleteJob(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/jobs/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete job');
    }
  }

  Future<void> applyForJob(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/jobs/$jobId/apply'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to apply for job');
    }
  }

  Future<List<dynamic>> getApplicants(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/jobs/$jobId/applicants'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load applicants');
    }
  }
}

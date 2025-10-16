import 'package:frontend/models/user.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String company;
  final String location;
  final int? salary;
  final List<String> skills;
  final User employer;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    this.salary,
    required this.skills,
    required this.employer,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      salary: (json['salary'] is String)
          ? (int.tryParse(json['salary']) ?? 0)
          : (json['salary'] as int?),
      skills: (json['skills'] != null)
          ? List<String>.from(json['skills'])
          : <String>[],
      employer: json['employer'] != null
          ? User.fromJson(json['employer'])
          : User.empty(), // tránh lỗi khi employer = null
    );
  }
}

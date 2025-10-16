import 'package:frontend/models/job.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<Job> favorites;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.favorites,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var favoriteJobs = <Job>[];

    if (json['favorites'] != null && json['favorites'] is List) {
      final favs = json['favorites'] as List;
      if (favs.isNotEmpty && favs.first is Map) {
        favoriteJobs = favs.map((fav) => Job.fromJson(fav)).toList();
      }
    }

    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      favorites: favoriteJobs,
    );
  }

  factory User.empty() {
    return User(id: '', name: '', email: '', role: '', favorites: []);
  }
}

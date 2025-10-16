import 'package:frontend/models/user.dart';

class Conversation {
  final String id;
  final List<User> participants;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    var participantsList = json['participants'] as List;
    List<User> participants = participantsList.map((i) => User.fromJson(i)).toList();

    return Conversation(
      id: json['_id'],
      participants: participants,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
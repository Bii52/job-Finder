class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['sender'] ?? json['senderId'] ?? '', // Backend trả về 'sender'
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

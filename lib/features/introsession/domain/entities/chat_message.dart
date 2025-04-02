class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String response_id;
  final DateTime timestamp;
  String? feedback;
  final bool isSelected;
  final double response_time;
  ChatMessage({
    required this.isUser,
    required this.text,
    required this.response_id,
    this.isSelected = false,
    this.feedback,
    required this.response_time,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        "message": text,
        "isUser": isUser,
        'response_id': response_id,
        "timestamp": timestamp.toIso8601String(),
        "feedback": feedback,
        'response_time': response_time
      };

  factory ChatMessage.fromJson(Map<String, dynamic> jsondata) {
    return ChatMessage(
      isUser: jsondata['isUser'] ?? false,
      text: jsondata['message'] ?? 'no message',
      response_id: jsondata['response_id'] ?? 'no_id',
      feedback: jsondata["feedback"] ?? "empty_string",
      response_time: jsondata['response_time'] ?? 0.0,
      timestamp: jsondata['timestamp'] != null
          ? DateTime.tryParse(jsondata['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static List<ChatMessage> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
  }

  ChatMessage copyWith({
    String? response_id,
    String? text,
    bool? isUser,
    bool? isSelected,
    required String feedback,
  }) {
    return ChatMessage(
        response_id: response_id ?? this.response_id,
        text: text ?? this.text,
        isUser: isUser ?? this.isUser,
        isSelected: isSelected ?? this.isSelected,
        feedback: feedback,
        response_time: response_time);
  }
}

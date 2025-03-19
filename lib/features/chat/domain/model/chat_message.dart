class ChatMessage {
  final String text;
  final bool isUser;
  final String response_id;
  final DateTime timestamp;
  String? feedback;
  final bool isSelected;
  ChatMessage({
    required this.isUser,
    required this.text,
    required this.response_id,
    this.isSelected = false,
    this.feedback,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  //converting the data from the chatmessage to the json data
  // Map<String, dynamic> toJson(ChatMessage message) {
  //   return {
  //     'text': message.text,
  //     'isUser': message.isUser,
  //     "timestamp": timestamp.toIso8601String(),
  //   };
  // }

  Map<String, dynamic> toJson() => {
        "message": text,
        "isUser": isUser,
        'response_id': response_id,
        "timestamp": timestamp.toIso8601String(),
        "feedback": feedback,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> jsondata) {
    return ChatMessage(
      isUser: jsondata['isUser'] ?? false,
      text: jsondata['message'] ?? 'no message',
      response_id: jsondata['response_id'] ?? 'no_id',
      feedback: jsondata["feedback"] ?? "empty_string",
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
    );
  }
}

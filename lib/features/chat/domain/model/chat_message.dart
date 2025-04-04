class ChatMessage {
  final String text;
  final bool isUser;
  final String responseId; // Changed from response_id to responseId
  final DateTime timestamp;
  String? feedback;
  final bool isSelected;
  final double responseTime; // Changed from response_time to responseTime
  final bool isFromHistory; // Add this new field

  ChatMessage({
    required this.isUser,
    required this.text,
    required this.responseId,
    this.isSelected = false,
    this.isFromHistory = false, // Default to false
    this.feedback,
    required this.responseTime,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        "message": text,
        "isUser": isUser,
        'response_id': responseId,
        "timestamp": timestamp.toIso8601String(),
        "feedback": feedback,
        'response_time': responseTime
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      isUser:
          json['role'] == 'AI' ? false : true, // Updated to match API response
      text: json['message'] ?? 'No message',
      responseId: json['response_id'] ?? 'no_id',
      feedback: json["feedback"] ?? "",
      responseTime: (json['response_time'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['created_at'] * 1000).toInt())
          : DateTime.now(),
    );
  }

  ChatMessage copyWith({
    String? responseId,
    String? text,
    bool? isUser,
    bool? isSelected,
    String? feedback,
    double? responseTime,
    bool? isFromHistory, // Add to copyWith
  }) {
    return ChatMessage(
      responseId: responseId ?? this.responseId,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isSelected: isSelected ?? this.isSelected,
      feedback: feedback ?? this.feedback,
      responseTime: responseTime ?? this.responseTime,
      isFromHistory: isFromHistory ?? this.isFromHistory, // Include in copy
    );
  }
}

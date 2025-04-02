class ChatResponse {
  final String role;
  final String responseId;
  final String message;
  final double responseTime;
  final String sessionTitle;

  ChatResponse({
    required this.role,
    required this.responseId,
    required this.message,
    required this.responseTime,
    required this.sessionTitle,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      role: json['role'] ?? "",
      responseId: json['response_id'] ?? "",
      message: json['message'] ?? "",
      responseTime: json['response_time'] ?? 0.0,
      sessionTitle: json['session_title'] ?? "",
    );
  }
}

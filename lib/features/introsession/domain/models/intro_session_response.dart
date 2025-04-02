class IntroSessionResponse {
  final String sessionId;
  final String message;

  IntroSessionResponse({
    required this.sessionId,
    required this.message,
  });

  factory IntroSessionResponse.fromJson(Map<String, dynamic> json) {
    return IntroSessionResponse(
      sessionId: json['session_id'] ?? "",
      message: json['message'] ?? "",
    );
  }
}

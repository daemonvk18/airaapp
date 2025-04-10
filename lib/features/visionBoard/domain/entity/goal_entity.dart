class VisionGoal {
  final String id;
  final String text;
  final String timestamp;

  VisionGoal({
    required this.id,
    required this.text,
    required this.timestamp,
  });

  factory VisionGoal.fromJson(Map<String, dynamic> json) {
    return VisionGoal(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp,
    };
  }
}

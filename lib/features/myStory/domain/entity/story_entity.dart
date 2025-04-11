class Story {
  final String content;

  Story({required this.content});

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      content: json['story'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'story': content,
    };
  }
}

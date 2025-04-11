import 'package:airaapp/features/myStory/domain/entity/story_entity.dart';

class StoryModel extends Story {
  StoryModel({required String content}) : super(content: content);

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      content: json['story'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'story': content,
    };
  }
}

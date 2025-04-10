import 'package:airaapp/features/visionBoard/domain/entity/goal_entity.dart';

class VisionGoalModel extends VisionGoal {
  VisionGoalModel({
    required super.id,
    required super.text,
    required super.timestamp,
  });

  factory VisionGoalModel.fromJson(Map<String, dynamic> json) {
    return VisionGoalModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

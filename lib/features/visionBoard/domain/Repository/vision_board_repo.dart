import 'package:airaapp/features/visionBoard/domain/entity/goal_entity.dart';

abstract class VisionBoardRepo {
  Future<List<VisionGoal>> getdreams();
  Future<VisionGoal> adddreams(String goal);
}

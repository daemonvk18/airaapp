import 'package:airaapp/features/myStory/domain/entity/story_entity.dart';

abstract class StoryRepository {
  Future<Story> generateStory();
}

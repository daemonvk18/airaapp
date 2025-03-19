import 'package:airaapp/features/profile/domain/model/profile.dart';

abstract class ProfileRepo {
  Future<ProfileModel> getProfile();
  Future<bool> updateProfile(ProfileModel profile);
}

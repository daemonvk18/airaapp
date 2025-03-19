import 'package:airaapp/core/network_service.dart';
import 'package:airaapp/features/profile/domain/model/profile.dart';
import 'package:airaapp/features/profile/domain/repository/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final networkService = NetworkService();

  @override
  Future<ProfileModel> getProfile() async {
    final data = await networkService.getProfile();
    return ProfileModel.fromJson(data);
  }

  @override
  Future<bool> updateProfile(ProfileModel profile) async {
    return await networkService.updateProfile(profile.toJson());
  }
}

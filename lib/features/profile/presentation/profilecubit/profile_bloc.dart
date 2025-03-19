import 'package:airaapp/features/profile/presentation/profilecubit/profile_events.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airaapp/features/profile/domain/repository/profile_repo.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepo profileRepo;

  ProfileBloc({required this.profileRepo}) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      debugPrint("📢 LoadProfile event received!");
      emit(ProfileLoading());
      try {
        final profile = await profileRepo.getProfile();
        debugPrint("✅ Profile loaded: ${profile.name}");
        emit(ProfileLoaded(profile: profile));
      } catch (e) {
        debugPrint("❌ Error loading profile: $e");
        emit(ProfileError(message: e.toString()));
      }
    });

    on<UpdateProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final success = await profileRepo.updateProfile(event.profile);
        debugPrint('called the update profile function');
        if (success) {
          final updatedProfile =
              await profileRepo.getProfile(); // Fetch updated profile
          debugPrint("✅ Profile updated successfully: ${updatedProfile.name}");
          emit(ProfileUpdated());
          emit(ProfileLoaded(profile: updatedProfile));
          add(LoadProfile()); // Reload profile after update
        } else {
          emit(ProfileError(message: "Failed to update profile"));
        }
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });
  }
}

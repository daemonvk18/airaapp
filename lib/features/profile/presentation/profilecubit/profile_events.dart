import 'package:airaapp/features/profile/domain/model/profile.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final ProfileModel profile;
  UpdateProfile({required this.profile});

  @override
  List<Object?> get props => [profile];
}

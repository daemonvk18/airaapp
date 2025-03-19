/*

AUTH STATES - declares the auth states of the application

*/

import 'package:airaapp/features/auth/domain/models/app_user.dart';

abstract class AuthState {}

//intial state
class AuthInitial extends AuthState {}

//loading state
class AuthLoading extends AuthState {}

//authenticated state
class Authenticated extends AuthState {
  final AppUser? appuser;
  Authenticated({this.appuser});
}

//unauthenticated state
class Unauthenticated extends AuthState {}

//error state
class AuthError extends AuthState {
  final String? message;
  AuthError({this.message});
}

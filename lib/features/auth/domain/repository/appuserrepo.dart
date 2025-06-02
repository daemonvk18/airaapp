/*

AUTH REPO: we will be basically outlining the authentication operations

*/

import 'package:airaapp/features/auth/domain/models/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginwithEmailPassword(String email, String password);
  Future<AppUser?> registerwithemailPassword(
      String email, String password, String username);
  Future<AppUser?> getCurrentuser();
  Future<String?> forgotPassword(
      {required String emailId, required String newPassword});
  Future<bool> logout();
}

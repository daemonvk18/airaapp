import 'package:airaapp/features/auth/data/firebase_auth_repo.dart';
import 'package:airaapp/features/auth/domain/models/app_user.dart';
import 'package:airaapp/features/auth/domain/repository/appuserrepo.dart';
import 'package:airaapp/features/auth/presentation/auth_states/authstate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  //final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  AuthCubit(FirebaseAuthRepo firebaseAuthRepo, {required this.authRepo})
      : super(AuthInitial());

  //check whether the user is autheticated or not
  void checkauthenticated() async {
    try {
      emit(AuthLoading());
      final user = await authRepo.getCurrentuser();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(appuser: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: "$e"));
      emit(Unauthenticated());
    }
  }

  //getter function for the currentUser
  AppUser? get currentUser => _currentUser;

  //login with email,pw
  Future<void> loginmethod(String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginwithEmailPassword(email, pw);
      if (user != null) {
        _currentUser = user;
        await _secureStorage.write(key: 'emailid', value: email);
        // Check if intro session is needed
        final introCompleted =
            await _secureStorage.read(key: '${email}intro_completed');
        // Ensure we always get a boolean value
        final needsIntroSession = introCompleted != 'true';
        emit(
            Authenticated(appuser: user, needsIntroSession: needsIntroSession));
      } else {
        emit(AuthError(message: "Invalid email or password"));
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'login failed $e'));
      emit(Unauthenticated());
    }
  }

  //register with email,pw,username
  Future<void> registemethod(String email, String pw, String username) async {
    try {
      emit(AuthLoading());
      final user =
          await authRepo.registerwithemailPassword(email, pw, username);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(appuser: user));
      } else {
        emit(AuthError(message: "Invalid email or password"));
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'registration failed $e'));
      emit(Unauthenticated());
    }
  }

  //logout
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      final response = await authRepo.logout();
      if (response == true) {
        emit(Unauthenticated());
      } else {
        emit(AuthError(message: 'logout failed due to some reason'));
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: '$e'));
      emit(Unauthenticated());
    }
  }

  //reset password
  Future<void> resetPassword(String newPassword, String emailId) async {
    try {
      emit(PasswordResetLoading());
      final success = await authRepo.forgotPassword(
          newPassword: newPassword, emailId: emailId);
      if (success == "Password reset successfully") {
        emit(PasswordResetSuccess('Password reset successfully'));
      } else {
        emit(PasswordResetFailure('Password reset failed'));
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(PasswordResetFailure(e.toString()));
      emit(AuthInitial());
    } finally {
      emit(Unauthenticated()); // Return to initial state
    }
  }
}

import 'package:airaapp/features/auth/domain/models/app_user.dart';
import 'package:airaapp/features/auth/domain/repository/appuserrepo.dart';
import 'package:airaapp/features/auth/presentation/auth_states/authstate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;
  //final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  AuthCubit({required this.authRepo}) : super(AuthInitial());

  //check whether the user is autheticated or not
  void checkauthenticated() async {
    // //first get the user
    // final AppUser? appuser = await authRepo.getCurrentuser();
    // //check for the null
    // if (appuser != null) {
    //   _currentUser = appuser;
    //   emit(Authenticated(appuser: appuser));
    // } else {
    //   emit(Unauthenticated());
    // }
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
    // try {
    //   emit(AuthLoading());
    //   final user = await authRepo.loginwithEmailPassword(email, pw);
    //   //check for the null values
    //   if (user != null) {
    //     _currentUser = user;
    //     emit(Authenticated(appuser: user));
    //   } else {
    //     emit(Unauthenticated());
    //   }
    // } catch (e) {
    //   emit(AuthError(message: e.toString()));
    //   emit(Unauthenticated());
    // }
    try {
      emit(AuthLoading());
      final user = await authRepo.loginwithEmailPassword(email, pw);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(appuser: user));
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
    // emit(AuthLoading());
    // try {
    //   //first get the user
    //   final user =
    //       await authRepo.registerwithemailPassword(email, pw, username);
    //   //check for the null value
    //   if (user != null) {
    //     _currentUser = user;
    //     emit(Authenticated());
    //   } else {
    //     emit(Unauthenticated());
    //   }
    // } catch (e) {
    //   emit(AuthError(message: e.toString()));
    //   emit(Unauthenticated());
    // }
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
      if (response) {
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
}

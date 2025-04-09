import 'dart:convert';

import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/core/network_service.dart';
import 'package:airaapp/features/auth/domain/models/app_user.dart';
import 'package:airaapp/features/auth/domain/repository/appuserrepo.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthRepo implements AuthRepo {
  //final FirebaseAuth firebaseauth = FirebaseAuth.instance;
  final NetworkService _networkService = NetworkService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final dataHistoryRepo = DataChatHistoryRepo();
  @override
  Future<AppUser?> getCurrentuser() async {
    // final currentUser = await firebaseauth.currentUser;
    // //check if the current user is null or not
    // if (currentUser == null) {
    //   return null;
    // }
    // //if not return the current user
    // return AppUser(
    //     email: currentUser.email!, uid: currentUser.uid, username: "");
    try {
      final token = await _secureStorage.read(key: 'session_token');
      if (token == null) {
        return null;
      }
      // ignore: unused_local_variable
      final response = await _networkService.getRequest(
          headers: {"Authorization": "Bearer $token"},
          ApiConstants.getUserEndpoint);
      if (response.containsKey('profile')) {
        return AppUser.fromJson(response['profile']);
      } else {
        throw Exception("User data not found in API response.");
      }
    } catch (e) {
      throw Exception("not found user:$e");
    }
  }

  @override
  Future<AppUser?> loginwithEmailPassword(String email, String password) async {
    try {
      final response = await _networkService.postRequest(
          ApiConstants.loginEndpoint, {"email": email, "password": password});
      AppUser user = AppUser.fromJson(response);
      await _secureStorage.write(key: 'user_token', value: user.token);
      //store the email as token
      await _secureStorage.write(
          key: 'emailid', value: response['user']['email']);
      //store the access_token
      await _secureStorage.write(
          key: 'session_token', value: response['access_token']);
      // Store refresh token
      await _secureStorage.write(
          key: 'refresh_token', value: response['refresh_token']);

      //streak logic...
      final now = DateTime.now();
      final todayStr =
          "${now.year}-${now.month}-${now.day}"; // format: 2025-04-08
      final lastLoginStr = await _secureStorage.read(key: 'today_logined_day');
      if (lastLoginStr == null || lastLoginStr != todayStr) {
        await _secureStorage.write(
            key: 'last_logined_day', value: lastLoginStr);
        await _secureStorage.write(key: 'today_logined_day', value: todayStr);

        // Maintain list of streak days
        final streakListStr = await _secureStorage.read(key: 'streak_days');
        List<String> streakDays = [];
        if (streakListStr != null) {
          streakDays = List<String>.from(jsonDecode(streakListStr));
        }

        if (!streakDays.contains(todayStr)) {
          streakDays.add(todayStr);
        }

        await _secureStorage.write(
            key: 'streak_days', value: jsonEncode(streakDays));
      }

      print(user.token);
      return user;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final response = await _networkService.logout();
      if (response) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        //call the save session,get_all_session,authorized_history from here
        //await _networkService.saveSessions();
        await _secureStorage.delete(key: 'refresh_token');
        await _secureStorage.delete(key: 'session_token');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('logout failed:$e');
    }
  }

  @override
  Future<AppUser?> registerwithemailPassword(
      String email, String password, String username) async {
    try {
      final response = await _networkService.postRequest(
        ApiConstants.registerEndpoint,
        {"email": email, "password": password, "username": username},
      );
      AppUser user = AppUser.fromJson(response);
      await _secureStorage.write(key: 'user_token', value: user.token);
      await _secureStorage.write(
          key: 'session_token', value: response['token']);
      return user;
    } catch (e) {
      throw Exception("registration failed: $e");
    }
  }
}

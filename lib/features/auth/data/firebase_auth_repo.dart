import 'dart:convert';
import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/core/network_service.dart';
import 'package:airaapp/features/auth/domain/models/app_user.dart';
import 'package:airaapp/features/auth/domain/repository/appuserrepo.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FirebaseAuthRepo implements AuthRepo {
  //final FirebaseAuth firebaseauth = FirebaseAuth.instance;
  final NetworkService _networkService = NetworkService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final dataHistoryRepo = DataChatHistoryRepo();
  @override
  Future<AppUser?> getCurrentuser() async {
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
      await _secureStorage.write(
          key: 'emailid', value: response['user']['email']);
      await _secureStorage.write(
          key: 'session_token', value: response['access_token']);
      await _secureStorage.write(
          key: 'refresh_token', value: response['refresh_token']);

// streak logic...
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month}-${now.day}";
      final emailKey =
          response['user']['email'] as String; // Ensure this is String

      final todayLoginKey = 'today_logined_day_$emailKey';
      final lastLoginKey = 'last_logined_day_$emailKey';
      final streakDaysKey = 'streak_days_$emailKey';
      final streakCountKey = 'streak_count_$emailKey';

      final lastLoginStr =
          // ignore: unnecessary_cast
          await _secureStorage.read(key: lastLoginKey) as String?;
      final todayLoginStr =
          // ignore: unnecessary_cast
          await _secureStorage.read(key: todayLoginKey) as String?;

// If we haven't logged in today
      if (todayLoginStr == null || todayLoginStr != todayStr) {
        // Update storage with today's login
        await _secureStorage.write(key: todayLoginKey, value: todayStr);

        // Parse the last login date if it exists
        DateTime? lastLoginDate;
        if (lastLoginStr != null) {
          final parts = lastLoginStr.split('-');
          lastLoginDate = DateTime(
              int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }

        final currentDate = DateTime.now();

        // Get current streak count
        final currentStreakStr =
            // ignore: unnecessary_cast
            await _secureStorage.read(key: streakCountKey) as String?;
        int currentStreak =
            currentStreakStr != null ? int.tryParse(currentStreakStr) ?? 0 : 0;

        // Check if this is consecutive (exactly 1 day after last login)
        if (lastLoginDate != null &&
            lastLoginDate.add(const Duration(days: 1)).day == currentDate.day &&
            lastLoginDate.add(const Duration(days: 1)).month ==
                currentDate.month &&
            lastLoginDate.add(const Duration(days: 1)).year ==
                currentDate.year) {
          // Consecutive day - increment streak
          currentStreak++;
        } else {
          // Not consecutive - reset streak to 1
          currentStreak = 1;
        }

        // Update streak count
        await _secureStorage.write(
            key: streakCountKey, value: currentStreak.toString());

        // Update last login date
        await _secureStorage.write(key: lastLoginKey, value: todayStr);

        // Update streak days list
        final streakListStr =
            // ignore: unnecessary_cast
            await _secureStorage.read(key: streakDaysKey) as String?;
        List<String> streakDays = [];
        if (streakListStr != null) {
          try {
            streakDays = List<String>.from(jsonDecode(streakListStr) as List);
          } catch (e) {
            streakDays = [];
          }
        }

        if (!streakDays.contains(todayStr)) {
          streakDays.add(todayStr);
          await _secureStorage.write(
              key: streakDaysKey, value: jsonEncode(streakDays));
        }
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
      await _secureStorage.write(key: 'emailid', value: response['email']);
      await _secureStorage.write(key: 'user_token', value: user.token);
      await _secureStorage.write(
          key: 'session_token', value: response['token']);
      return user;
    } catch (e) {
      throw Exception("registration failed: $e");
    }
  }

  @override
  Future<String> forgotPassword(
      {required String emailId, required String newPassword}) async {
    //get the email_id first...

    try {
      final response = await http.post(
          Uri.parse(ApiConstants.forgotPasswordEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': emailId, 'new_password': newPassword}));
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print(jsonDecode(response.body));
        return decodedResponse['message'];
      } else {
        throw Exception('password reset failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

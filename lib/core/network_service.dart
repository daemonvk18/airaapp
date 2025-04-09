import 'dart:convert';
import 'package:airaapp/core/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  final secureStorage = FlutterSecureStorage();
  //post request
  Future<Map<String, dynamic>> postRequest(
      String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to connect to API: ${response.body}');
    }
  }

  //get request
  Future<Map<String, dynamic>> getRequest(String url,
      {Map<String, String>? headers}) async {
    try {
      final final_url = Uri.parse(url);
      final response = await http.get(final_url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "GET request failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error in GET request: $e");
    }
  }

  //post request for chat
  Future<Map<String, dynamic>> postChat(
      String url, Map<String, dynamic> data) async {
    final token = await secureStorage.read(key: 'session_token');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        if (token != null)
          "Authorization": "Bearer $token", // Add token if available
      },
      body: jsonEncode(data),
    );
    print(token);
    if (response.statusCode == 200) {
      try {
        final decodedResponse =
            jsonDecode(response.body); // Ensure JSON decoding
        return decodedResponse;
      } catch (e) {
        throw Exception("Failed to decode response: ${response.body}");
      }
    } else {
      throw Exception("Failed to send message: ${response.body}");
    }
  }

  //get chat history call
  Future<Map<String, dynamic>> getChatHistory(String sessionId) async {
    final token = await secureStorage.read(key: 'session_token');
    final response = await http.get(
      Uri.parse('${ApiConstants.chatHistoryEndpoint}?session_id=$sessionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  //post logout call
  Future<bool> logout() async {
    final token = await secureStorage.read(key: 'session_token');
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.logoutEndpoint),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        await secureStorage.delete(key: 'session_token');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception("logout failed:$e");
    }
  }

  //get profile
  Future<Map<String, dynamic>> getProfile() async {
    final token = await secureStorage.read(key: 'session_token');

    final response = await http.get(
      Uri.parse(ApiConstants.getUserEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodeResponse = jsonDecode(response.body);
      await secureStorage.write(
          key: 'user_id_reminder', value: decodeResponse['profile']['user_id']);
      print(decodeResponse);
      return decodeResponse;
    } else {
      throw Exception("Failed to fetch profile");
    }
  }

  //update profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    final token = await secureStorage.read(key: 'session_token');

    final response = await http.put(
      Uri.parse(ApiConstants.updateprofileEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileData),
    );

    if (response.statusCode == 200) {
      print('profile updated sucessfully');
      return true;
    } else {
      return false;
    }
  }

  // save session post request
  Future<void> saveSessions() async {
    final token = await secureStorage.read(key: 'session_token');
    final response = await http.post(
      Uri.parse(ApiConstants.saveSessionsEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      //get the name of the session
    } else {
      print('unable to save the session');
    }
  }

  //all sessions post request
  Future<Map<String, dynamic>> getallSessions() async {
    final token = await secureStorage.read(key: 'session_token');
    final response = await http.get(
      Uri.parse(ApiConstants.allsessionsEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      //return the response
      return jsonDecode(response.body);
    } else {
      throw Exception('error failed to get all sessions');
    }
  }

  //chat intro session api call(post)....
  Future<Map<String, dynamic>> introSession() async {
    //get the url and parse it first....
    final baseUrl = ApiConstants.introSessionEndpoint;

    try {
      //get the authorization bearer token....
      final token = await secureStorage.read(key: 'session_token');

      //check if the token is null...
      if (token == null) {
        throw Exception('session ended');
      }
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to start intro session: ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  //create new session....
  Future<Map<String, dynamic>> createNewSession() async {
    final token = await secureStorage.read(key: 'session_token');
    try {
      final response = await http
          .post(Uri.parse(ApiConstants.createNewSessionEndpoint), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create new session');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

class ApiConstants {
  static const String baseUrl = "https://aira-v2-2.onrender.com/api";
  static const String loginEndpoint = "$baseUrl/auth/login";
  static const String registerEndpoint = "$baseUrl/auth/register";
  static const String getUserEndpoint = '$baseUrl/user/profile';
  static const String chatEndpoint = '$baseUrl/chat/send';
  static const String chatHistoryEndpoint = '$baseUrl/chat/history';
  static const String sendfeedbackpoint = '$baseUrl/feedback/submit';
  static const String logoutEndpoint = '$baseUrl/auth/logout';
  static const String updateprofileEndpoint = '$baseUrl/user/update';
  static const String saveSessionsEndpoint = '$baseUrl/chat/save_session';
  static const String allsessionsEndpoint = '$baseUrl/chat/sessions';
}

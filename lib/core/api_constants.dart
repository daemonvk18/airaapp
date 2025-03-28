class ApiConstants {
  static const String baseUrl = "http://127.0.0.1:5000/api";
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
  static const String refreshTokenEndpoint = '$baseUrl/auth/refresh';
  static const String introSessionEndpoint = '$baseUrl/chat/start_intro';
}

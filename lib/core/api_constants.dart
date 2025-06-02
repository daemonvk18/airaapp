class ApiConstants {
  static const String baseUrl =
      "https://aira-v2-2.onrender.com/api"; //https://aira-v2-2.onrender.com/api
  static const String loginEndpoint = "$baseUrl/auth/login";
  static const String registerEndpoint = "$baseUrl/auth/register";
  static const String forgotPasswordEndpoint = '$baseUrl/auth/reset-password';
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
  static const String createNewSessionEndpoint = '$baseUrl/chat/new_session';
  static const String getReminderEndpoint =
      '$baseUrl/reminder/get_all_reminders';
  static const String addReminderEndpoint = '$baseUrl/reminder/add_reminder';
  static const String updateReminderEndpoint =
      '$baseUrl/reminder/update_reminder';
  static const String deleteReminderEndpoint =
      '$baseUrl/reminder/delete_reminder';
  static const String getDreamsEndpoint = '$baseUrl/visionboard/get_goals';
  static const String addDreamsEndpoint =
      "$baseUrl/visionboard/add_custom_goal";
  static const String getStoryEndpoint = '$baseUrl/user/generate_story';
  static const String getAnalyzeEndpoint = '$baseUrl/sentiment/analyze';
  static const String getSentimentEndpoint =
      '$baseUrl/sentiment/get_sentiments';
  static const String sendMotivationEndpoint = '$baseUrl/user/send_motivation';
  static const String deleteChatSessionEndpoint = '$baseUrl/chat/sessions';
}

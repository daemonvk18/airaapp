class AppUser {
  final String uid;
  final String email;
  final String username;
  final String token;
  AppUser(
      {required this.email,
      required this.uid,
      required this.username,
      required this.token});

  //converting the app data to the json data
  Map<String, dynamic> toJsonData(AppUser user) {
    return {'uid': user.uid, 'email': user.email, 'username': user.username};
  }

  //converting the json data to the app user
  factory AppUser.fromJson(Map<String, dynamic> jsondata) {
    final profile = jsondata['profile'] ?? {};
    return AppUser(
        email: profile['email'] ?? "",
        uid: profile['user_id'] ?? "",
        username: profile['username'] ?? 'Unknown',
        token: "");
  }
}

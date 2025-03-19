class ProfileModel {
  final String name;
  final String email;
  final String profilephoto;
  final String password;

  ProfileModel(
      {required this.name,
      required this.email,
      required this.profilephoto,
      required this.password});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final profiledata = json['profile'];
    return ProfileModel(
        name: profiledata['username'] ?? '',
        email: profiledata['email'] ?? '',
        password: profiledata['password'] ?? "",
        profilephoto: profiledata['profile_photo'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'username': name,
      'email': email,
      'profile_photo': profilephoto,
      'password': password
    };
  }
}

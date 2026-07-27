class ProfileModel {
  final String username;
  final String email;
  final String about;

  ProfileModel(
      {required this.username, required this.email, required this.about});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      username: json['username'],
      email: json['email'],
      about: json['about'],
    );
  }
}

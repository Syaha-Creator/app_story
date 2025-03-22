class User {
  final String userId;
  final String name;
  final String token;

  User({required this.userId, required this.name, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      name: json['name'],
      token: json['token'],
    );
  }
}

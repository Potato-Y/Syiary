class User {
  int? userId;
  String? email;
  String? nickname;

  User({this.userId, this.email, this.nickname});

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'] as int?,
        email: json['email'] as String?,
        nickname: json['nickname'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'nickname': nickname,
      };
}

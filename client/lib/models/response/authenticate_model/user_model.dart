class UserModel {
  int? userId;
  String? email;
  String? nickname;

  UserModel({this.userId, this.email, this.nickname});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
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

class SignupModel {
  int? userId;
  String? email;
  String? nickname;

  SignupModel({this.userId, this.email, this.nickname});

  factory SignupModel.fromJson(Map<String, dynamic> json) => SignupModel(
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

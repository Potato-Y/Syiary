import 'user.dart';

class AuthenticateModel {
  String? accessToken;
  String? refreshToken;
  User? user;

  AuthenticateModel({this.accessToken, this.refreshToken, this.user});

  factory AuthenticateModel.fromJson(Map<String, dynamic> json) {
    return AuthenticateModel(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user?.toJson(),
      };
}

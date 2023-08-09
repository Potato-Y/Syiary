import 'package:flutter/foundation.dart';

class UserInfo with ChangeNotifier, DiagnosticableTreeMixin {
  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  String? _nickname;
  String? _email;

  set setUserId(int userId) {
    _userId = userId;
  }

  set setNickName(String nickname) {
    _nickname = nickname;
  }

  set setEmail(String email) {
    _email = email;
  }

  set setAccessToken(String accessToken) {
    _accessToken = accessToken;
  }

  set setRefreshToken(String refreshToken) {
    _refreshToken = refreshToken;
  }

  get accessToken => _accessToken;

  get refreshToken => _refreshToken;

  get userId => _userId;

  get nickname => _nickname;

  get email => _email;
}

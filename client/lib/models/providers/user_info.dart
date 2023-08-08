import 'package:flutter/foundation.dart';

class UserInfo with ChangeNotifier, DiagnosticableTreeMixin {
  String? _accessToken;
  String? _refreshToken;

  set setAccessToken(String accessToken) {
    _accessToken = accessToken;
  }

  set setRefreshToken(String refreshToken) {
    _refreshToken = refreshToken;
  }

  get accessToken => _accessToken;

  get refreshToken => _refreshToken;
}

import 'package:flutter/foundation.dart';

class UserInfo with ChangeNotifier, DiagnosticableTreeMixin {
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

  get userId => _userId;

  get nickname => _nickname;

  get email => _email;
}

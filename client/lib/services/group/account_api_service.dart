import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syiary_client/enum/request_method.dart';
import 'package:syiary_client/exception/account_exception.dart';

import '../../models/response/authenticate_model/authenticate_model.dart';
import '../../models/response/authenticate_model/user_model.dart';
import '../api_base.dart';

class AccountApiService extends ApiBase {
  AccountApiService() : super();

  /// 로그인한다.
  Future<AuthenticateModel> getAuthentication(
      {required String email, required String password}) async {
    final url = Uri.parse('$baseUrl/api/authenticate');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var body = {"email": email, "password": password};

    final response =
        await http.post(url, headers: headers, body: json.encode(body));

    debugPrint('code: ${response.statusCode}');

    if (response.statusCode == HttpStatus.ok) {
      final dynamic body = jsonDecode(response.body);
      AuthenticateModel model = AuthenticateModel.fromJson(body);

      return model;
    }

    throw AccountException('로그인에 실패하였습니다.');
  }

  /// 회원가입한다.
  Future<void> signup(String email, String password, String nickname) async {
    final url = Uri.parse('$baseUrl/api/signup');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var body = {"email": email, "password": password, "nickname": nickname};

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    debugPrint('signup. code: ${response.statusCode}');

    if (response.statusCode == HttpStatus.created) {
      return;
    }

    throw AccountException('회원가입에 실패하였습니다.');
  }

  /// 유저 정보를 발급받는다.
  Future<UserModel> getMyUserInfo() async {
    var url = Uri.parse('$baseUrl/api/user');
    final http.StreamedResponse response =
        await requestRestApi(RequestMethod.get, url);

    if (response.statusCode == HttpStatus.ok) {
      String body = await getResponseBody(response);
      UserModel user = UserModel.fromJson(jsonDecode(body));
      return user;
    }

    throw AccountException('계정 정보를 불러올 수 없습니다.');
  }
}

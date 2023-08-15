import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syiary_client/enum/request_method.dart';

import '../../models/response/authenticate_model/authenticate_model.dart';
import '../../models/response/authenticate_model/user_model.dart';
import '../api_base.dart';

class AccountApiService extends ApiBase {
  AccountApiService() : super();

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

    throw Error();
  }

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

    throw Error();
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

    throw Error();
  }
}

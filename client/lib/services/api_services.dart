import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:syiary_client/models/response/authenticate_model/authenticate_model.dart';
import 'package:syiary_client/models/response/authenticate_model/user_model.dart';
import 'package:syiary_client/models/response/token_reissue_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const String _post = 'POST';
  static const String _get = 'GET';

  /// 인증을 추가한 RestAPi 처리를 진행한다.
  /// 토큰이 만료된 경우 토큰을 다시 발급받고, 다시 요청한다.
  static Future<http.StreamedResponse> requestRestApi(String type, Uri url,
      {JsonCodec? body}) async {
    final box = Hive.box('app');

    String accessToken = box.get('user_access_token');
    String refreshToken = box.get('user_refresh_token');

    Future<http.StreamedResponse> request() async {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final req = http.Request(type, url);
      req.headers.addAll(headers);
      if (body != null) {
        req.body = json.encode(body);
      }

      var response = await req.send();
      return response;
    }

    // 받은 정보를 통해 요청한다.
    var response = await request();

    // 토큰의 기간이 만료된 것으로 예상될 경우 다시 발급받는다.
    if (response.statusCode == 403) {
      try {
        // 토큰을 새로 발급받는다.
        TokenReissueModel token = await tokenReissue(accessToken, refreshToken);
        accessToken = token.accessToken!;
        box.put('user_access_token', accessToken);
      } catch (e) {
        // 토큰을 갱신하지 못한 경우 관련 정보를 삭제한다.
        box.delete('user_access_token');
        box.delete('user_refresh_token');

        Fluttertoast.showToast(msg: '계정 정보를 불러올 수 없습니다.');
        throw Error();
      }

      // 변경된 토큰을 통해 재요청한다.
      response = await request();
    }

    // 문제가 없을 경우 response를 반환한다.
    if (response.statusCode != 403) {
      return response;
    }

    // 또 실패한 경우 예외 발생
    throw Error();
  }

  /// 새로운 토큰을 발급 받는다.
  static Future<TokenReissueModel> tokenReissue(
      String accessToken, String refreshToken) async {
    final url = Uri.parse('$baseUrl/api/token');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var body = {"accessToken": accessToken, "refreshToken": refreshToken};

    final response =
        await http.post(url, headers: headers, body: json.encode(body));

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      return TokenReissueModel.fromJson(body);
    }

    throw Error();
  }

  static Future<AuthenticateModel> getAuthentication(
      {required String email, required String password}) async {
    final url = Uri.parse('$baseUrl/api/authenticate');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var body = {"email": email, "password": password};

    final response =
        await http.post(url, headers: headers, body: json.encode(body));

    debugPrint('code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      AuthenticateModel model = AuthenticateModel.fromJson(body);

      return model;
    }

    throw Error();
  }

  static Future<void> signup(
      String email, String password, String nickname) async {
    final url = Uri.parse('$baseUrl/api/signup');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var body = {"email": email, "password": password, "nickname": nickname};

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    debugPrint('signup. code: ${response.statusCode}');

    if (response.statusCode == 201) {
      return;
    }

    throw Error();
  }

  /// 유저 정보를 발급받는다.
  static Future<UserModel> getMyUserInfo() async {
    var url = Uri.parse('$baseUrl/api/user');
    final http.StreamedResponse response = await requestRestApi(_get, url);

    if (response.statusCode == 200) {
      String body = await _getResponseBody(response);
      UserModel user = UserModel.fromJson(jsonDecode(body));
      return user;
    }

    throw Error();
  }

  static Future<String> _getResponseBody(http.StreamedResponse response) async {
    return await response.stream.bytesToString();
  }
}

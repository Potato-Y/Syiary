import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:syiary_client/enum/request_method.dart';
import 'package:syiary_client/exception/account_exception.dart';
import 'package:syiary_client/exception/response_exception.dart';
import 'package:syiary_client/models/response/token_reissue_model.dart';

class ApiBase {
  final String baseUrl = 'http://localhost:8080';
  final String accessTokenDbKey = 'user_access_token';
  final String refreshTokenDbKey = 'user_refresh_token';

  ApiBase();

  /// 인증을 추가한 RestAPi 처리를 진행한다.
  /// 토큰이 만료된 경우 토큰을 다시 발급받고, 다시 요청한다.
  Future<http.StreamedResponse> requestRestApi(RequestMethod method, Uri url,
      {Map<String, dynamic>? body}) async {
    final box = Hive.box('app');

    String accessToken = box.get(accessTokenDbKey);
    String refreshToken = box.get(refreshTokenDbKey);

    Future<http.StreamedResponse> request() async {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final req = http.Request(method.value, url);
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
    if (response.statusCode == HttpStatus.forbidden) {
      try {
        // 토큰을 새로 발급받는다.
        TokenReissueModel token = await tokenReissue(accessToken, refreshToken);
        accessToken = token.accessToken!;
        box.put('user_access_token', accessToken);
      } catch (e) {
        // 토큰을 갱신하지 못한 경우 관련 정보를 삭제한다.
        clearToken(box);

        throw AccountException('계정 정보를 불러올 수 없습니다.');
      }

      // 변경된 토큰을 통해 재요청한다.
      response = await request();
    }

    // 문제가 없을 경우 response를 반환한다.
    if (response.statusCode != HttpStatus.forbidden) {
      return response;
    }

    // 또 실패한 경우 예외 발생
    throw ResponseException('요청에 실패하였습니다.');
  }

  /// form-data 방식의 요청을 한다.
  Future<Response> requestForm(RequestMethod method, String url,
      {Map<String, dynamic>? body}) async {
    final box = Hive.box('app');

    String accessToken = box.get('user_access_token');
    String refreshToken = box.get('user_refresh_token');

    Future<Response> request() async {
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
      };

      Dio dio = Dio();

      FormData data = FormData.fromMap({});
      if (body != null) {
        // form 데이터가 있으면 추가한다.
        data = FormData.fromMap(body);
      }

      Response response = await dio.request(
        url,
        options: Options(
          method: method.value,
          headers: headers,
        ),
        data: data,
      );

      return response;
    }

    // 받은 정보를 통해 요청한다.
    var response = await request();

    if (response.statusCode == HttpStatus.forbidden) {
      try {
        // 토큰을 새로 발급받는다.
        TokenReissueModel token = await tokenReissue(accessToken, refreshToken);
        accessToken = token.accessToken!;
        box.put('user_access_token', accessToken);
      } catch (e) {
        // 토큰을 갱신하지 못한 경우 관련 정보를 삭제한다.
        box.delete('user_access_token');
        box.delete('user_refresh_token');

        throw AccountException('계정 정보를 불러올 수 없습니다.');
      }

      // 변경된 토큰을 통해 재요청한다.
      response = await request();
    }

    // 문제가 없을 경우 response를 반환한다.
    if (response.statusCode != HttpStatus.forbidden) {
      return response;
    }

    // 또 실패한 경우 예외 발생
    throw ResponseException('요청에 실패하였습니다.');
  }

  /// 새로운 토큰을 발급 받는다.
  Future<TokenReissueModel> tokenReissue(
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

    throw AccountException('계정 정보를 불러올 수 없습니다.');
  }

  Future<String> getResponseBody(http.StreamedResponse response) async {
    return await response.stream.bytesToString();
  }

  /// db에 저장된 토큰 정보를 삭제한다.
  void clearToken(Box<dynamic> box) {
    box.delete('user_access_token');
    box.delete('user_refresh_token');
  }
}

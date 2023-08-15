import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:syiary_client/enum/request_method.dart';
import 'package:syiary_client/models/response/token_reissue_model.dart';

class ApiBase {
  final String baseUrl = 'http://localhost:8080';

  ApiBase();

  /// 인증을 추가한 RestAPi 처리를 진행한다.
  /// 토큰이 만료된 경우 토큰을 다시 발급받고, 다시 요청한다.
  Future<http.StreamedResponse> requestRestApi(RequestMethod method, Uri url,
      {Map<String, dynamic>? body}) async {
    final box = Hive.box('app');

    String accessToken = box.get('user_access_token');
    String refreshToken = box.get('user_refresh_token');

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
        box.delete('user_access_token');
        box.delete('user_refresh_token');

        Fluttertoast.showToast(msg: '계정 정보를 불러올 수 없습니다.'); // TODO UI 영역으로 이동 필요
        throw Error();
      }

      // 변경된 토큰을 통해 재요청한다.
      response = await request();
    }

    // 문제가 없을 경우 response를 반환한다.
    if (response.statusCode != HttpStatus.forbidden) {
      return response;
    }

    // 또 실패한 경우 예외 발생
    throw Error();
  }

  /// form-data 방식의 요청을 한다.
  Future requestForm(RequestMethod method, String url,
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

      var response = await dio.request(
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

        Fluttertoast.showToast(msg: '계정 정보를 불러올 수 없습니다.'); // TODO UI 영역으로 이동 필요
        throw Error();
      }

      // 변경된 토큰을 통해 재요청한다.
      response = await request();
    }

    // 문제가 없을 경우 response를 반환한다.
    if (response.statusCode != HttpStatus.forbidden) {
      return response;
    }

    // 또 실패한 경우 예외 발생
    throw Error();
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

    throw Error();
  }

  Future<String> getResponseBody(http.StreamedResponse response) async {
    return await response.stream.bytesToString();
  }
}

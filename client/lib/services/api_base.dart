import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:syiary_client/models/response/authenticate_model/authenticate_model.dart';
import 'package:syiary_client/models/response/authenticate_model/user_model.dart';
import 'package:syiary_client/models/response/create_group_model.dart';
import 'package:syiary_client/models/response/group_info_model.dart';
import 'package:syiary_client/models/response/token_reissue_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const String _post = 'POST';
  static const String _get = 'GET';
  static const String _delete = 'DELETE';

  /// 인증을 추가한 RestAPi 처리를 진행한다.
  /// 토큰이 만료된 경우 토큰을 다시 발급받고, 다시 요청한다.
  static Future<http.StreamedResponse> requestRestApi(String type, Uri url,
      {Map<String, dynamic>? body}) async {
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

        Fluttertoast.showToast(msg: '계정 정보를 불러올 수 없습니다.'); // TODO UI 영역으로 이동 필요
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

  /// form-data 방식의 요청을 한다.
  static Future requestForm(String type, String url,
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
          method: type,
          headers: headers,
        ),
        data: data,
      );

      return response;
    }

    // 받은 정보를 통해 요청한다.
    var response = await request();

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

        Fluttertoast.showToast(msg: '계정 정보를 불러올 수 없습니다.'); // TODO UI 영역으로 이동 필요
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

  /// 새로운 그룹을 생성한다.
  static Future<CreateGroupModel> createGroup(String groupName) async {
    var url = Uri.parse('$baseUrl/api/groups');
    var body = {"groupName": groupName};
    final http.StreamedResponse response =
        await requestRestApi(_post, url, body: body);

    if (response.statusCode == 201) {
      String body = await _getResponseBody(response);
      CreateGroupModel group = CreateGroupModel.fromJson(jsonDecode(body));
      return group;
    }

    throw Error();
  }

  /// 그룹 목록을 가져온다.
  static Future<List<GroupInfoModel>> getGroupList() async {
    var url = Uri.parse('$baseUrl/api/groups');
    final http.StreamedResponse response = await requestRestApi(_get, url);

    if (response.statusCode == 200) {
      String body = await _getResponseBody(response);
      List<dynamic> jsonList = jsonDecode(body);
      List<GroupInfoModel> groups =
          jsonList.map((json) => GroupInfoModel.fromJson(json)).toList();

      return groups;
    }

    throw Error();
  }

  /// 그룹 정보 불러오기
  static Future<GroupInfoModel> getGroupInfo(String groupUri) async {
    var url = Uri.parse('$baseUrl/api/groups/$groupUri');
    final http.StreamedResponse response = await requestRestApi(_get, url);

    if (response.statusCode == 200) {
      String body = await _getResponseBody(response);
      GroupInfoModel group = GroupInfoModel.fromJson(jsonDecode(body));

      return group;
    }

    throw Error();
  }

  /// 새로운 게시글 전송
  static Future uploadPost(String groupUri,
      {String? content, List<XFile>? files}) async {
    var url = '$baseUrl/api/groups/$groupUri/posts';

    // 받아온 파일을 업로드하기 위해 가공한다.
    List<MultipartFile> multipartFiles = [];
    if (files != null) {
      multipartFiles = files.map((file) {
        String? type = lookupMimeType(file.name);
        if (type == null) {
          throw Error();
        }
        return MultipartFile.fromFileSync(file.path,
            contentType: MediaType.parse(type));
      }).toList();
    }

    // 전송할 정보를 포함시킨다.
    Map<String, dynamic> body = {
      'content': content ?? '',
      'files': multipartFiles
    };

    await requestForm(_post, url, body: body);
  }

  /// 새로운 사용자를 추가한다.
  static Future signupMemberGroup(String groupUri,
      {required String? email}) async {
    var url = Uri.parse('$baseUrl/api/groups/$groupUri/members');
    var body = {'userEmail': email ?? ''};
    final http.StreamedResponse response = await requestRestApi(
      _post,
      url,
      body: body,
    );

    if (response.statusCode != 204) {
      throw Error();
    }
  }

  static Future deleteGroup(String groupUri, String groupSign) async {
    var url = Uri.parse('$baseUrl/api/groups/$groupUri');
    var body = {"groupNameSign": groupSign};
    final http.StreamedResponse response =
        await requestRestApi(_delete, url, body: body);

    if (response.statusCode != 204) {
      throw Error();
    }
  }

  static Future<String> _getResponseBody(http.StreamedResponse response) async {
    return await response.stream.bytesToString();
  }
}

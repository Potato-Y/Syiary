import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syiary_client/models/response/authenticate_model/authenticate_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

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
}

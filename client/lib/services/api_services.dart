import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syiary_client/models/requests/authenticate_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  static Future<AuthenticationModel> getAuthentication(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/authenticate');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var body = {"email": email, "password": password};

    final response =
        await http.post(url, headers: headers, body: json.encode(body));

    debugPrint('code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final dynamic token = jsonDecode(response.body);
      AuthenticationModel model = AuthenticationModel.fromJson(token);

      return model;
    }

    throw Error();
  }
}

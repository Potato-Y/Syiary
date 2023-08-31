import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:syiary_client/enum/request_method.dart';
import 'package:syiary_client/exception/post_exception.dart';
import 'package:syiary_client/models/response/post_model.dart';

import '../api_base.dart';

class PostApiService extends ApiBase {
  PostApiService() : super();

  /// 새로운 게시글 전송
  Future uploadPost(String groupUri,
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

    Response response = await requestForm(RequestMethod.post, url, body: body);

    if (response.statusCode != HttpStatus.created) {
      throw PostException('업로드에 실패하였습니다.');
    }
  }

  /// post 목록을 가져온다.
  Future<List<PostModel>> getPosts(String groupUri, int page) async {
    var url = Uri.parse('$baseUrl/api/groups/$groupUri/posts?page=$page');
    final http.StreamedResponse response =
        await requestRestApi(RequestMethod.get, url);

    if (response.statusCode == HttpStatus.ok) {
      String body = await getResponseBody(response);
      List<dynamic> jsonList = jsonDecode(body);
      List<PostModel> posts =
          jsonList.map((json) => PostModel.fromJson(json)).toList();

      debugPrint(posts.toString());

      return posts;
    }

    throw PostException('피드를 불러올 수 없습니다.');
  }
}

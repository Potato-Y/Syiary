import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:syiary_client/enum/request_method.dart';

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

    await requestForm(RequestMethod.post, url, body: body);
  }
}

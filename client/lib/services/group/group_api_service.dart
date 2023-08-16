import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:syiary_client/enum/request_method.dart';
import 'package:syiary_client/exception/group_exception.dart';
import 'package:syiary_client/models/response/group_members/group_members_model.dart';

import '../../models/response/create_group_model.dart';
import '../../models/response/group_info_model.dart';
import '../api_base.dart';

class GroupApiService extends ApiBase {
  GroupApiService() : super();

  /// 새로운 그룹을 생성한다.
  Future<CreateGroupModel> createGroup(String groupName) async {
    var url = Uri.parse('$baseUrl/api/groups');
    var body = {"groupName": groupName};
    final http.StreamedResponse response =
        await requestRestApi(RequestMethod.post, url, body: body);

    if (response.statusCode == HttpStatus.created) {
      String body = await getResponseBody(response);
      CreateGroupModel group = CreateGroupModel.fromJson(jsonDecode(body));
      return group;
    }

    throw GroupException('그룹 생성에 실패하였습니다.');
  }

  /// 그룹 목록을 가져온다.
  Future<List<GroupInfoModel>> getGroupList() async {
    var url = Uri.parse('$baseUrl/api/groups');
    final http.StreamedResponse response =
        await requestRestApi(RequestMethod.get, url);

    if (response.statusCode == HttpStatus.ok) {
      String body = await getResponseBody(response);
      List<dynamic> jsonList = jsonDecode(body);
      List<GroupInfoModel> groups =
          jsonList.map((json) => GroupInfoModel.fromJson(json)).toList();

      return groups;
    }

    throw GroupException('그룹 목록을 불러오기에 실패하였습니다.');
  }

  /// 그룹 정보 불러오기
  Future<GroupInfoModel> getGroupInfo(String groupUri) async {
    var url = Uri.parse('$baseUrl/api/groups/$groupUri');
    final http.StreamedResponse response =
        await requestRestApi(RequestMethod.get, url);

    if (response.statusCode == HttpStatus.ok) {
      String body = await getResponseBody(response);
      GroupInfoModel group = GroupInfoModel.fromJson(jsonDecode(body));

      return group;
    }

    throw GroupException('그룹 정보를 가져오지 못하였습니다.');
  }

  /// 새로운 사용자를 추가한다.
  Future signupMemberGroup(String groupUri, {required String? email}) async {
    var url = Uri.parse('$baseUrl/api/groups/$groupUri/members');
    var body = {'userEmail': email ?? ''};
    final http.StreamedResponse response = await requestRestApi(
      RequestMethod.post,
      url,
      body: body,
    );

    if (response.statusCode != HttpStatus.noContent) {
      throw GroupException('사용자 추가에 실패하였습니다.');
    }
  }

  /// 그룹을 삭제한다.
  Future deleteGroup(String groupUri, String groupSign) async {
    var url = Uri.parse('$baseUrl/api/groups/$groupUri');
    var body = {"groupNameSign": groupSign};
    final http.StreamedResponse response =
        await requestRestApi(RequestMethod.delete, url, body: body);

    if (response.statusCode != HttpStatus.noContent) {
      throw GroupException('그룹을 삭제하지 못하였습니다.');
    }
  }

  /// 그룹 멤버 리스트를 불러온다.
  Future<GroupMembersModel> getGroupMembers(String groupUri) async {
    var url = Uri.parse('$baseUrl/api/groups/$groupUri/members');
    final http.StreamedResponse response =
        await requestRestApi(RequestMethod.get, url);

    if (response.statusCode == HttpStatus.ok) {
      String body = await getResponseBody(response);
      GroupMembersModel groupMembersModel =
          GroupMembersModel.fromJson(jsonDecode(body));
      return groupMembersModel;
    }

    throw GroupException('그룹 멤버를 불러오는 중 오류가 발생했습니다.');
  }

  /// 그룹에서 멤버를 내보낸다.
  Future leaveMember(String groupUri, String email) async {
    var url = Uri.parse('$baseUrl/api/groups/$groupUri/members');
    var body = {"userEmail": email};
    final http.StreamedResponse response =
        await requestRestApi(RequestMethod.delete, url, body: body);

    if (response.statusCode == HttpStatus.noContent) {
      return;
    }

    throw GroupException('멤버를 내보내지 못하였습니다.');
  }
}

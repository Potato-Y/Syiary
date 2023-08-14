import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syiary_client/models/response/group_info_model.dart';
import 'package:syiary_client/screens/group_body_screen.dart';
import 'package:syiary_client/services/api_services.dart';

class GroupScreen extends StatelessWidget {
  final String groupUri;

  const GroupScreen({super.key, required this.groupUri});

  Future<GroupInfoModel> _loadGroup() async {
    try {
      GroupInfoModel group = await ApiService.getGroupInfo(groupUri);
      return group;
    } catch (e) {
      Fluttertoast.showToast(msg: '그룹 정보를 불러오지 못 하였습니다.');
      throw Error();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(groupUri);
    return FutureBuilder(
      future: _loadGroup(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data!.groupName!),
            ),
            body: GroupBodyScreen(
              groupUri: groupUri,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(),
          body: const CircularProgressIndicator(),
        );
      },
    );
  }
}

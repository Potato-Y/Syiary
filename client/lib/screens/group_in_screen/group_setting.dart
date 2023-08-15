import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syiary_client/exception/group_exception.dart';
import 'package:syiary_client/models/providers/user_info.dart';
import 'package:syiary_client/services/group/group_api_service.dart';

import '../../exception/account_exception.dart';
import '../../exception/response_exception.dart';
import '../../models/response/group_info_model.dart';

class GroupSetting extends StatelessWidget {
  final String groupUri;

  GroupSetting({super.key, required this.groupUri});

  final _emailTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // final double itemWidth = MediaQuery.of(context).size.width * 0.8;
    const double itemHeight = 50;

    return Scaffold(
      appBar: AppBar(title: const Text('Group settings')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          // color: Colors.deepOrangeAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingTitle('사용자 추가'),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: itemHeight,
                      child: TextField(
                        controller: _emailTextEditingController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (!EmailValidator.validate(
                          _emailTextEditingController.text)) {
                        Fluttertoast.showToast(msg: 'Email이 아닙니다.');
                        return;
                      }

                      try {
                        await GroupApiService().signupMemberGroup(groupUri,
                            email: _emailTextEditingController.text);
                        Fluttertoast.showToast(msg: '사용자를 추가하였습니다.');
                        _emailTextEditingController.text = '';
                      } on GroupException catch (e) {
                        Fluttertoast.showToast(msg: e.message);
                      } on AccountException catch (e) {
                        Fluttertoast.showToast(msg: e.message);
                        context.go('/login');
                      } on ResponseException catch (e) {
                        Fluttertoast.showToast(msg: e.message);
                      } catch (e) {
                        debugPrint(e.toString());
                        Fluttertoast.showToast(msg: '오류가 발생했습니다.');
                      }
                    },
                    child: const Text('추가'),
                  ),
                ],
              ),
              const SettingTitle('사용자 제거'),
              const SizedBox(
                height: 300,
                child: Placeholder(),
              ),
              const SettingTitle(
                '그룹 삭제',
                color: Colors.red,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
                child: Text('그룹 삭제를 위해서는 그룹 이름을 입력하세요'),
              ),
              DeleteGroupContainer(groupUri: groupUri),
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteGroupContainer extends StatefulWidget {
  final String groupUri;

  const DeleteGroupContainer({super.key, required this.groupUri});

  @override
  State<DeleteGroupContainer> createState() => _DeleteGroupContainerState();
}

class _DeleteGroupContainerState extends State<DeleteGroupContainer> {
  final TextEditingController _textEditingController = TextEditingController();

  Future<GroupInfoModel?> _loadGroup() async {
    try {
      GroupInfoModel group =
          await GroupApiService().getGroupInfo(widget.groupUri);
      return group;
    } on GroupException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } on AccountException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      context.go('/login');
    } on ResponseException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(msg: '오류가 발생했습니다.');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 50;

    return FutureBuilder(
      future: _loadGroup(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // host가 아닌 경우 방 나가기 반환
          if (snapshot.data!.hostUser!.email !=
              context.read<UserInfo>().email) {
            return FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red[200],
              ),
              child: const Text(
                '방 나가기',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () {},
            );
          }

          final String groupName = snapshot.data!.groupName!;

          return Column(
            children: [
              SizedBox(
                height: itemHeight,
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: groupName,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[200],
                ),
                child: const Text(
                  '삭제',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  if (groupName != _textEditingController.text) {
                    Fluttertoast.showToast(msg: '그룹 이름을 정확하게 입력하세요.');
                    return;
                  }

                  try {
                    GroupApiService().deleteGroup(
                        widget.groupUri, _textEditingController.text);

                    context.go('/');
                  } on GroupException catch (e) {
                    Fluttertoast.showToast(msg: e.message);
                  } on AccountException catch (e) {
                    Fluttertoast.showToast(msg: e.message);
                    context.go('/login');
                  } on ResponseException catch (e) {
                    Fluttertoast.showToast(msg: e.message);
                  } catch (e) {
                    debugPrint(e.toString());
                    Fluttertoast.showToast(msg: '오류가 발생했습니다.');
                  }
                },
              )
            ],
          );
        }

        return const CircularProgressIndicator();
      },
    );
  }
}

class SettingTitle extends StatelessWidget {
  final String text;
  final Color? color;

  const SettingTitle(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 20, 0, 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syiary_client/exception/group_exception.dart';
import 'package:syiary_client/models/providers/user_info.dart';
import 'package:syiary_client/models/response/authenticate_model/user_model.dart';
import 'package:syiary_client/models/response/group_members/group_members_model.dart';
import 'package:syiary_client/services/group/group_api_service.dart';
import 'package:syiary_client/themes/app_original_color.dart';

import '../../exception/account_exception.dart';
import '../../exception/response_exception.dart';
import '../../models/response/group_info_model.dart';

class GroupSetting extends StatefulWidget {
  final String groupUri;

  const GroupSetting({super.key, required this.groupUri});

  @override
  State<GroupSetting> createState() => _GroupSettingState();
}

class _GroupSettingState extends State<GroupSetting> {
  final _emailTextEditingController = TextEditingController();

  late Future<GroupMembersModel> userModels;

  void reloadGroupMembers() {
    setState(() {
      userModels = GroupApiService().getGroupMembers(widget.groupUri);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final double itemWidth = MediaQuery.of(context).size.width * 0.8;
    const double itemHeight = 50;

    userModels = GroupApiService().getGroupMembers(widget.groupUri);

    return Scaffold(
      appBar: AppBar(title: const Text('Group settings')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          // color: Colors.deepOrangeAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingTitle('멤버 추가'),
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
                        await GroupApiService().signupMemberGroup(
                            widget.groupUri,
                            email: _emailTextEditingController.text);
                        Fluttertoast.showToast(msg: '사용자를 추가하였습니다.');
                        _emailTextEditingController.text = '';

                        reloadGroupMembers();
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
              const SettingTitle('멤버 목록'),
              SizedBox(
                height: 300,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: GroupMemberListWidget(
                      groupUri: widget.groupUri,
                      userModels: userModels,
                      reloadGroupMembers: reloadGroupMembers),
                ),
              ),
              const SettingTitle(
                '그룹 삭제',
                color: Colors.red,
              ),
              DeleteGroupContainer(groupUri: widget.groupUri),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupMemberListWidget extends StatelessWidget {
  final Future<GroupMembersModel> userModels;
  final String groupUri;
  final Function reloadGroupMembers;

  const GroupMemberListWidget(
      {super.key,
      required this.groupUri,
      required this.userModels,
      required this.reloadGroupMembers});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userModels,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<UserModel> users = [];

          users.add(snapshot.data!.hostUser!);
          if (snapshot.data!.memberUser!.isNotEmpty) {
            users.addAll(snapshot.data!.memberUser!);
          }

          return ListView.separated(
            scrollDirection: Axis.vertical,
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            users[index].nickname!,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(users[index].email!),
                        ],
                      ),
                    ),
                    if (index == 0)
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: appOriginalColor.shade50,
                        ),
                        child: const Text('Host'),
                      ),
                    if (snapshot.data!.hostUser!.email ==
                            context.read<UserInfo>().email &&
                        index > 0) // 호스트인 경우만 버튼을 보이기, 호스트는 내보내기 없애기
                      TextButton(
                        child: const Text('내보내기'),
                        onPressed: () async {
                          try {
                            await GroupApiService()
                                .leaveMember(groupUri, users[index].email!);
                          } catch (e) {
                            Fluttertoast.showToast(msg: '요청을 실패하였습니다.');
                          } finally {
                            reloadGroupMembers();
                          }
                        },
                      ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              height: 0.5,
              color: Colors.black45,
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
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
            return Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
                      child: Text('그룹을 탈퇴합니다.'),
                    ),
                  ],
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red[200],
                  ),
                  child: const Text(
                    '방 나가기',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await GroupApiService()
                          .leaveMember(widget.groupUri, null);

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
                ),
              ],
            );
          }

          final String groupName = snapshot.data!.groupName!;

          return Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
                    child: Text('그룹 삭제를 위해서는 그룹 이름을 입력하세요.'),
                  ),
                ],
              ),
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
                  '그룹 삭제',
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

                    Fluttertoast.showToast(msg: '그룹을 완전히 삭제하는데 시간이 걸립니다.');
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

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../models/response/group_info_model.dart';
import '../../services/api_services.dart';

class GroupSetting extends StatelessWidget {
  final String groupUri;

  GroupSetting({super.key, required this.groupUri});

  final _emailTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double itemWidth = MediaQuery.of(context).size.width * 0.8;
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
                    onPressed: () {},
                    child: const Text('추가'),
                  )
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

  Future<GroupInfoModel> _loadGroup() async {
    try {
      GroupInfoModel group = await ApiService.getGroupInfo(widget.groupUri);
      return group;
    } catch (e) {
      Fluttertoast.showToast(msg: '그룹 정보를 불러오지 못 하였습니다.');
      throw Error();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 50;

    return FutureBuilder(
      future: _loadGroup(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
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
                    ApiService.deleteGroup(
                        widget.groupUri, _textEditingController.text);

                    context.go('/');
                  } catch (e) {
                    Fluttertoast.showToast(msg: '그룹 삭제에 실패하였습니다.');
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

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:syiary_client/services/group/group_api_service.dart';
import 'package:syiary_client/themes/app_original_color.dart';

import '../exception/account_exception.dart';
import '../exception/group_exception.dart';
import '../exception/response_exception.dart';
import '../models/response/group_info_model.dart';

class GroupSelectScreen extends StatelessWidget {
  const GroupSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double itemWidth = MediaQuery.of(context).size.width * 0.9;
    const double itemHeight = 50;

    ListView makeList(AsyncSnapshot<List<GroupInfoModel>?> snapshot) {
      return ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          if (snapshot.data == null) {
            return ListView();
          }
          var group = snapshot.data![index];

          return GestureDetector(
            onTap: () {
              context.push('/groups/${group.groupUri}');
            },
            child: Column(
              children: [
                Container(
                  width: itemWidth - 10,
                  height: itemHeight,
                  // margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: appOriginalColor.shade100,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    group.groupName!,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(
          height: 10,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syiary'),
        actions: [
          IconButton(
            onPressed: () => context.push('/setting'),
            tooltip: 'Setting',
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                width: itemWidth,
                height: MediaQuery.of(context).size.width * 0.6,
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: appOriginalColor.shade50,
                ),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.pushReplacement('/groups'),
                      icon: const Icon(Icons.refresh),
                      label: const Text('새로고침'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    FutureBuilder(
                      future: _loadGroup(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return ElevatedButton(
                            onPressed: () => context.pushReplacement('/groups'),
                            child: const Text('다시 불러오기'),
                          );
                        }

                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Text('참여한 그룹 정보가 없습니다.');
                          }
                          return Expanded(child: makeList(snapshot));
                        }

                        return const CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/create_group');
                },
                icon: const Icon(Icons.add),
                label: const Text('추가하기'),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<GroupInfoModel>?> _loadGroup() async {
    try {
      List<GroupInfoModel> groups = await GroupApiService().getGroupList();
      return groups;
    } on GroupException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } on AccountException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } on ResponseException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(msg: '오류가 발생했습니다.');
    }
    return null;
  }
}

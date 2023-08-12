import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:syiary_client/models/response/create_group_model.dart';
import 'package:syiary_client/services/api_services.dart';

class CreateGroupSelectScreen extends StatefulWidget {
  const CreateGroupSelectScreen({super.key});

  @override
  State<CreateGroupSelectScreen> createState() =>
      _CreateGroupSelectScreenState();
}

class _CreateGroupSelectScreenState extends State<CreateGroupSelectScreen> {
  final _groupNameController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final double itemWidth = MediaQuery.of(context).size.width * 0.8;
    const double itemHeight = 50;

    goGroupScreen(String groupUri) {
      context.pushReplacement('/groups/$groupUri');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('새로운 그룹 만들기'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                // Group name text Field
                width: itemWidth,
                height: itemHeight,
                child: TextField(
                  enabled: !_loading,
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Group name',
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true;
                          });

                          try {
                            CreateGroupModel group =
                                await ApiService.createGroup(
                                    _groupNameController.text);

                            goGroupScreen(group.groupUri!);
                          } catch (e) {
                            Fluttertoast.showToast(msg: '그룹을 만드는데 실패하였습니다.');
                          }
                        },
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('만들기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

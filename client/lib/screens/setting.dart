import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:syiary_client/services/group/account_api_service.dart';
import 'package:syiary_client/widgets/setting_title_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingTitleWidget('로그아웃'),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[200],
                ),
                onPressed: () {
                  // token 삭제
                  final box = Hive.box('app');
                  AccountApiService().clearToken(box);

                  // 홈으로 이동
                  context.pushReplacement('/');
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

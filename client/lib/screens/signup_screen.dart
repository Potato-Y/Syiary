import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syiary_client/models/response/authenticate_model/authenticate_model.dart';
import 'package:syiary_client/services/group/account_api_service.dart';

import '../models/providers/user_info.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final pw2Controller = TextEditingController();
  final nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double itemWidth = MediaQuery.of(context).size.width * 0.8;
    const double itemHeight = 50;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syiary 시작하기'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textFieldTitle('Email'),
              textField(
                width: itemWidth,
                height: itemHeight,
                controller: emailController,
                hint: '이메일을 입력하세요.',
                last: false,
              ),
              textFieldTitle('Password'),
              textField(
                width: itemWidth,
                height: itemHeight,
                controller: pwController,
                hint: '비밀번호를 입력하세요.',
                last: false,
                obscureText: true,
              ),
              textFieldTitle('Password check'),
              textField(
                width: itemWidth,
                height: itemHeight,
                controller: pw2Controller,
                hint: '비밀번호를 다시 입력하세요.',
                last: false,
                obscureText: true,
              ),
              textFieldTitle('Nickname'),
              textField(
                width: itemWidth,
                height: itemHeight,
                controller: nicknameController,
                hint: '별명을 입력하세요.',
                last: true,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: ElevatedButton(
                  onPressed: () async {
                    // 텍스트가 빈 곳이 있는지 확인
                    if (emailController.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Email이 비어있습니다.');
                    }
                    if (pwController.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Password가 비어있습니다.');
                    }
                    if (pw2Controller.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Password check가 비어있습니다.');
                    }
                    if (nicknameController.text.replaceAll(' ', '').isEmpty) {
                      Fluttertoast.showToast(msg: 'Nickname이 비어있습니다.');
                    }

                    // email 검증
                    if (!EmailValidator.validate(emailController.text)) {
                      Fluttertoast.showToast(msg: 'Email이 올바르지 않습니다.');
                    }
                    // 비밀번호와 비밀번호 확인이 동일한지 확인
                    if (pwController.text != pw2Controller.text) {
                      Fluttertoast.showToast(msg: 'Password가 동일하지 않습니다.');
                      return;
                    }

                    try {
                      await AccountApiService().signup(
                        emailController.text,
                        pwController.text,
                        nicknameController.text,
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                          msg: '회원가입에 실패하였습니다. 이메일을 다시 확인하세요.');

                      return;
                    }

                    // 회원가입 성공 후 로그인 진행
                    try {
                      AuthenticateModel authentication =
                          await AccountApiService().getAuthentication(
                        email: emailController.text,
                        password: pwController.text,
                      );

                      if (context.mounted) {
                        debugPrint(
                            'signup getAuthentication. context mounted.');
                        context.read<UserInfo>().setUserId =
                            authentication.user!.userId!;
                        context.read<UserInfo>().setEmail =
                            authentication.user!.email!;

                        context.go('/groups');
                      }
                    } catch (e) {
                      Fluttertoast.showToast(msg: '회원가입에 성공했으나, 로그인에 실패하였습니다.');
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: const Text('회원가입'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox textField(
      {required double width,
      required double height,
      required TextEditingController controller,
      required String hint,
      required bool last,
      bool? obscureText}) {
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        obscureText: obscureText ?? false,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
      ),
    );
  }

  Container textFieldTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 10, bottom: 10),
      child: Text(title),
    );
  }
}

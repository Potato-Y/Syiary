import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syiary_client/models/providers/user_info.dart';
import 'package:syiary_client/models/response/authenticate_model/authenticate_model.dart';
import 'package:syiary_client/services/group/account_api_service.dart';
import 'package:syiary_client/widgets/logo_widget.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final pwController = TextEditingController();

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
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: logo(),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text('Syiary'),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                // Email text Field
                width: itemWidth,
                height: itemHeight,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Email',
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                // Password Text Field
                width: itemWidth,
                height: itemHeight,
                child: TextField(
                  controller: pwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Password',
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (emailController.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Email이 비어있습니다.');
                      return;
                    }
                    if (!EmailValidator.validate(emailController.text)) {
                      Fluttertoast.showToast(msg: 'Email이 아닙니다.');
                      return;
                    }
                    if (pwController.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Password가 비어있습니다.');
                      return;
                    }

                    try {
                      AuthenticateModel authentication =
                          await AccountApiService().getAuthentication(
                        email: emailController.text,
                        password: pwController.text,
                      );

                      debugPrint('access: ${authentication.accessToken}');
                      debugPrint('refresh: ${authentication.refreshToken}');
                      debugPrint('nickname: ${authentication.user}');

                      final box = Hive.box('app');
                      box.put('user_access_token', authentication.accessToken);
                      box.put(
                          'user_refresh_token', authentication.refreshToken);

                      if (context.mounted) {
                        context.read<UserInfo>().setUserId =
                            authentication.user!.userId!;
                        context.read<UserInfo>().setEmail =
                            authentication.user!.email!;
                        context.read<UserInfo>().setNickName =
                            authentication.user!.nickname!;

                        context.go('/groups');
                      }
                    } catch (e) {
                      Fluttertoast.showToast(msg: 'Email 혹은 Password가 틀렸습니다.');
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: itemWidth,
                height: 1,
                child: Container(
                  color: Colors.black26,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/signup');
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: const Text('Signup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

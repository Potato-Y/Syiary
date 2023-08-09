import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syiary_client/models/providers/user_info.dart';
import 'package:syiary_client/models/requests/authenticate_model/authenticate_model.dart';
import 'package:syiary_client/services/api_services.dart';
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
        backgroundColor: Theme.of(context)
            .colorScheme
            .inversePrimary, // TODO 추후 추가할 앱 색상에 맞춰 변경
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
                          await ApiService.getAuthentication(
                              emailController.text, pwController.text);

                      debugPrint('access: ${authentication.accessToken}');
                      debugPrint('refresh: ${authentication.refreshToken}');
                      debugPrint('nickname: ${authentication.user}');

                      if (context.mounted) {
                        context.read<UserInfo>().setAccessToken =
                            authentication.accessToken!;
                        context.read<UserInfo>().setRefreshToken =
                            authentication.refreshToken!;
                        context.read<UserInfo>().setUserId =
                            authentication.user!.userId!;
                        context.read<UserInfo>().setEmail =
                            authentication.user!.email!;

                        // TODO 메인 페이지로 이동
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
                  onPressed: () {},
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

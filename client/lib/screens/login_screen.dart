import 'package:flutter/material.dart';
import 'package:syiary_client/models/requests/authenticate_model.dart';
import 'package:syiary_client/services/api_services.dart';
import 'package:syiary_client/widgets/logo_widget.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final idController = TextEditingController();
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
                controller: idController,
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
                  AuthenticationModel authentication =
                      await ApiService.getAuthentication(
                          idController.text, pwController.text);

                  debugPrint('access: ${authentication.accessToken}');
                  debugPrint('refresh: ${authentication.refreshToken}');

                  // TODO token 상태관리에 추가
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
    );
  }
}

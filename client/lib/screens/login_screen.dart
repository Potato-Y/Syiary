import 'package:flutter/material.dart';

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Syiary 시작하기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                onPressed: () {},
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

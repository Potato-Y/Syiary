import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syiary_client/themes/app_original_color.dart';

class GroupSelectScreen extends StatelessWidget {
  const GroupSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double itemWidth = MediaQuery.of(context).size.width * 0.9;
    const double itemHeight = 50;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syiary'),
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
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: appOriginalColor.shade50,
                ),
                child: Column(
                  children: [
                    FutureBuilder(
                      future: _loadGroup(),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Column(
                                children: [
                                  Container(
                                    width: itemWidth - 10,
                                    height: itemHeight,
                                    margin:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: appOriginalColor.shade100,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      '그룹 이름',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
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

  Future _loadGroup() async {}
}

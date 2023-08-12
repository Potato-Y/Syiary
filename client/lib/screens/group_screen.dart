import 'package:flutter/material.dart';

class GroupScreen extends StatelessWidget {
  final String groupUri;

  const GroupScreen({super.key, required this.groupUri});

  @override
  Widget build(BuildContext context) {
    debugPrint(groupUri);
    return Placeholder(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('group'),
        ),
      ),
    );
  }
}

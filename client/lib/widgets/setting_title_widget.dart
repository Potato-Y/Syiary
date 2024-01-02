import 'package:flutter/material.dart';

class SettingTitleWidget extends StatelessWidget {
  final String text;
  final Color? color;

  const SettingTitleWidget(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 20, 0, 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

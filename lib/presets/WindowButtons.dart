import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class Windowbuttons extends StatelessWidget {
  const Windowbuttons({super.key});

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        MinimizeWindowButton(),
        MaximizeWindowButton(),
        CloseWindowButton(),
      ],
    );
  }
}
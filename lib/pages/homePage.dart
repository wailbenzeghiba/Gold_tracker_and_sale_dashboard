import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/presets/leftSide.dart';
import 'package:gold_tracking_desktop_stock_app/presets/rightSide.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Leftside(),
        Rightside(),
      ]),
    );
  }
}

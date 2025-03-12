import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class Leftside extends StatelessWidget {
  const Leftside({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 200  , child: Container(color: Theme.of(context).primaryColor,child: Column(children: [WindowTitleBarBox(child: MoveWindow(),)],),),);
  }
}
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/presets/leftSide.dart';
import 'package:gold_tracking_desktop_stock_app/presets/rightSideDashboard.dart';
import 'package:gold_tracking_desktop_stock_app/presets/WindowButtons.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Leftside(),
          Expanded(
            child: Container(
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  WindowTitleBarBox(
                    child: Row(
                      children: [
                        Expanded(child: MoveWindow()),
                        Windowbuttons(),
                      ],
                    ),
                  ),
                  Expanded(child: RightSideDashboard()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
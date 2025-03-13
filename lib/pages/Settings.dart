import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:gold_tracking_desktop_stock_app/presets/WindowButtons.dart';
import 'package:gold_tracking_desktop_stock_app/presets/leftSide.dart';
import 'package:gold_tracking_desktop_stock_app/presets/RightSideSettings.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Leftside(),
          Expanded(
            child: Column(
              children: [
                // Window title bar
                WindowTitleBarBox(
                  child: Row(
                    children: [
                      Expanded(child: MoveWindow()),
                      Windowbuttons(),
                    ],
                  ),
                ),
                // Replace Expanded with Flexible or SizedBox
                Flexible(
                  child: RightSideSettings(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

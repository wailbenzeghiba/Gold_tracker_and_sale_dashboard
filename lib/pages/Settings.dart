import 'package:flutter/material.dart';
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
            child: Container(
              color: Theme.of(context).cardColor, // ✅ Consistent background color
              child: RightSideSettings(),
            ),
          ),
        ],
      ),
    );
  }
}

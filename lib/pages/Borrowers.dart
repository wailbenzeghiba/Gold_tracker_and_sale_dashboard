import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/presets/leftSide.dart';
import 'package:gold_tracking_desktop_stock_app/presets/RightSideBorrowers.dart';

class Borrowers extends StatelessWidget {
  const Borrowers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Leftside(),
          Expanded(
            child: Container(
              color: Theme.of(context).cardColor, // ✅ Consistent background color
              child: RightSideBorrowers(),
            ),
          ),
        ],
      ),
    );
  }
}

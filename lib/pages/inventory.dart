import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/presets/leftSide.dart';
import 'package:gold_tracking_desktop_stock_app/presets/rightSideStock.dart';

class Inventory extends StatelessWidget {
  const Inventory ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Leftside(),
        RightsidestockT()
      ]),
    );
  }
}
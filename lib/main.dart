import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/pages/Dashboard.dart';
import 'package:gold_tracking_desktop_stock_app/theme/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  // Set the database factory
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
  doWhenWindowReady(() {
    appWindow.size = const Size(800, 600);
    appWindow.minSize = const Size(800, 600);
    appWindow.show();
    appWindow.title = "Stock";
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: WindowBorder(
        color: Colors.black,
        width: 1,
        child: const Dashboard(),
      ),
    );
  }
}

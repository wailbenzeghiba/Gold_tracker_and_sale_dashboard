import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor:  Color.fromARGB(255, 22, 22, 25),
      secondaryHeaderColor: Color.fromARGB(255, 39, 38, 39),
      cardColor: Color.fromARGB(255, 199, 195, 199),
    
      
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        color: Colors.blue,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 12, 43, 68),
      secondaryHeaderColor: Color.fromARGB(51, 31, 86, 135),
      cardColor:Color.fromARGB(255, 199, 195, 199),
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        color: Colors.blueGrey,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blueGrey,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
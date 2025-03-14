import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyProvider with ChangeNotifier {
  String _apiKey = '';

  String get apiKey => _apiKey;

  ApiKeyProvider() {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('api_key') ?? '';
    notifyListeners();
  }

  Future<void> setApiKey(String apiKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', apiKey);
    _apiKey = apiKey;
    notifyListeners();
  }
}
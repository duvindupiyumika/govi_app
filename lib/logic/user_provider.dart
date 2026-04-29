import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _currentFarmerId = "qgluZKUSRDKu6ykeTXTJ";

  String get currentFarmerId => _currentFarmerId;

  void setFarmerId(String id) {
    _currentFarmerId = id;
    notifyListeners();
  }
}
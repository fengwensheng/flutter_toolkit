import 'package:flutter/material.dart';

class NightSSHNotifier extends ChangeNotifier {
  List<String> _authentications = [];
  List<Map> _connects = [];
  List<Map> get connects => _connects;
  List<String> get authentications => _authentications;
  void addConnect(Map connectInfo) {
    _connects.add(connectInfo);
    notifyListeners();
  }

  void addAuthentications(String str) {
    _authentications.add(str);
    notifyListeners();
  }
}

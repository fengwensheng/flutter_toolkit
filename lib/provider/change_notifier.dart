import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toolkit/main.dart';

class HomePageNotifier extends ChangeNotifier {
  String _currentRoute = "";

  String get currentRoute => _currentRoute;
  changePage(String routeName) {
    setCurrentRoute(routeName);
    // Navigator.of(pushContext).pop();
    Future.delayed(Duration(milliseconds: 200), () {
      Navigator.of(pushContext).pushReplacementNamed(routeName);
    });
    notifyListeners();
  }

  setCurrentRoute(String routeName) {
    _currentRoute = routeName;
  }
}

class LoginNotifier extends ChangeNotifier {
  String _userTitle = "登录到M工具箱";
  String get userTitle => _userTitle;

  updataTitle(String newTitle) {
    if (_userTitle != newTitle) {
      print("设置新的标题$newTitle");
      _userTitle = newTitle;
      notifyListeners();
    }
  }
}

class MToolKitNotifier extends ChangeNotifier {
  Brightness _primaryColorBrightness = Brightness.light;
  Color _backgroundColor = Colors.white;
  Color _cardColor = Colors.white;
  Color _fontsColor = Color(0xff4b5c76);
  Color get backgroundColor => _backgroundColor;
  Color get cardColor => _cardColor;
  Color get fontsColor => _fontsColor;
  Brightness get primaryColorBrightness => _primaryColorBrightness;

  changeMode(ThemeMode themeMode) {
    if (themeMode == ThemeMode.dark) {
      _backgroundColor = Colors.black;
      _cardColor = Color(0xff303030);
      _fontsColor = Colors.white;
      notifyListeners();
    } else if (themeMode == ThemeMode.light) {
      _backgroundColor = Color(0xfffafafa);
      _cardColor = Colors.white;
      _fontsColor = Color(0xff4b5c76);
      notifyListeners();
    }
  }

  changeBright(Brightness _bright) {
    if (_primaryColorBrightness != _bright) {
      print("更改亮度为$_bright");
      _primaryColorBrightness = _bright;
      notifyListeners();
    }
  }
}

class ConsoleNotifier extends ChangeNotifier {
  int _time;
  bool _consoleCanPop;
  Timer _timeTicker;

  int get time => _time;
  bool get consoleCanPop => _consoleCanPop;
  initTimer() {
    _time ??= 0;
    _consoleCanPop ??= false;
    if (_timeTicker == null) {
      _timeTicker = Timer.periodic(
        Duration(seconds: 1),
        (timer) {
          _time = timer.tick;
          notifyListeners();
        },
      );
    }
  }

  disposeTimer() {
    _timeTicker.cancel();
  }
}

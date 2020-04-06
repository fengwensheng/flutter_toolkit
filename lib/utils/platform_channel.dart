import 'package:flutter/services.dart';


class PlatformChannel {
  static const Toast = const MethodChannel("Toast");
  static const First2 = const MethodChannel("First2");
  // static const Linux = const MethodChannel("Linux");
  static const First3 = const MethodChannel("First3");
  static const Drawer = const MethodChannel("DrawerHeader");
  static const Root = const MethodChannel("permission");
  static const Game = const MethodChannel("Game");
  static const JuanZheng = const MethodChannel("SomeThing");
  static const Decompile = const MethodChannel("Decompile");
  static const Setting = const MethodChannel("Setting");
  static const SendBroadcast = const MethodChannel("SendBroadcast");
  static const AppInfo = const MethodChannel("App");
  static const GetAppIcon = const MethodChannel("GetAppIcon");
  static const RootTools = const MethodChannel("Root");
}

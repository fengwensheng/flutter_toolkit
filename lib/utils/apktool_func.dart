import 'dart:io';
import 'package:flutter_toolkit/utils/platform_channel.dart';




String getExecTmpFilePath() {
  int _index = 0;
  String _logpath = "/data/data/com.nightmare/files/Apktool/apktool$_index";
  for (; File("$_logpath").existsSync(); _index++) {
    _logpath = "/data/data/com.nightmare/files/Apktool/apktool$_index";
  }
  return _logpath;
}

Future setOutputFile(String _logpath) async {
  await PlatformChannel.Decompile.invokeMethod("logout", _logpath);
}

import 'dart:io';

import 'package:flutter_toolkit/common/envirpath.dart';

//自己的info
class Info {
  static final String infoPath = EnvirPath.filesPath + "/MToolkit/info.list";
  static String getValue(String key) {
    try {
      List<String> infoList = File(infoPath).readAsStringSync().split("\n");
      String value = infoList[
              infoList.indexWhere((info) => info.contains(RegExp("$key=.*")))]
          .replaceAll("$key=", "");
      return value;
    } catch (e) {
      return "";
    }
  }

  static setValue(String key, Object value) {
    print(Directory(EnvirPath.filesPath + "/MToolkit").existsSync());
    if (!Directory(EnvirPath.filesPath + "/MToolkit").existsSync()) {
      Directory(EnvirPath.filesPath + "/MToolkit")
          .createSync(recursive: true);
    }
    String details;
    try {
      details = File(infoPath).readAsStringSync();
    } catch (e) {
      File(infoPath).writeAsStringSync("");
      details = File(infoPath).readAsStringSync();
    }
    if (details.contains(key)) {
      details = details.replaceAll(RegExp("$key=.*"), "$key=$value");
    } else {
      details += "\n$key=$value";
    }
    File(infoPath).writeAsStringSync(details.trim());
  }
}

import 'dart:io';

import 'package:flutter_toolkit/common/envirpath.dart';

class BookMarks {
  static void addMarks(String path) async {
    List<String> tmpMarks = [];
    File marksFile = File("${EnvirPath.filesPath}/FileManager/bookmarks");
    if (await marksFile.exists()) {
      tmpMarks = await marksFile.readAsLines();
    }
    tmpMarks.add(path);
    await marksFile.writeAsString(tmpMarks.join("\n"));
  }

  static void removeMarks(String path) async {
    List<String> tmpMarks = [];
    File marksFile = File("${EnvirPath.filesPath}/FileManager/bookmarks");
    if (await marksFile.exists()) {
      tmpMarks = await marksFile.readAsLines();
    }
    tmpMarks.removeAt(tmpMarks.indexOf(path));
    await marksFile.writeAsString(tmpMarks.join("\n"));
  }

  static Future<List<String>> getBookMarks() async {
    List<String> tmpMarks = [];
    File marksFile = File("${EnvirPath.filesPath}/FileManager/bookmarks");
    if (await marksFile.exists()) {
      tmpMarks = await marksFile.readAsLines();
    }
    return tmpMarks;
  }
}

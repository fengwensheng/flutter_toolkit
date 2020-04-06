import 'dart:io';

import 'package:flutter_toolkit/main.dart';
import 'package:path_provider/path_provider.dart';
getWorkDirectory() async {
    documentsDir ??=await PlatformUtil.workDirectory();
}

class PlatformUtil {
  static String getRealPath(String prePath) {
    if (Platform.isWindows)
      return prePath.replaceAll("/", "\\");
    else
      return prePath;
  }

  static workDirectory() async {
    String tmp;
    if (Platform.isAndroid)
      tmp = (await getExternalStorageDirectory())
          .path
          .replaceAll("/Android/data/com.nightmare/files", ""); //初始化外部储存的路径
    else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      tmp = "${FileSystemEntity.parentOf(Platform.resolvedExecutable)}";
    }
    return tmp;
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter_toolkit/common/envirpath.dart';
import 'package:flutter_toolkit/model/toolkit_info.dart';
import 'package:flutter_toolkit/utils/process.dart';


Future<bool> rootCheck() async {
  String result = "";
  if (Platform.isAndroid) {
     result=await CustomProcess.exec("id", getStdout: true, getStderr: false);
    print("id=========>$result");
    print("root检查的结果====>${result.trim()=="uid=0(root) gid=0(root)"}");
  }
  if (result == "uid=0(root) gid=0(root)") {
    ToolkitInfo.isRoot = true;
    return true;
  } else {
    ToolkitInfo.isRoot = false;
    return false;
  }
}

bool hasBusyBox() {
  //检测busybox是否存在
  if (File(EnvirPath.busyboxPath).existsSync() ||
      File("/system/xbin/busybox").existsSync()) {
    return true;
  } else {
    return false;
  }
}

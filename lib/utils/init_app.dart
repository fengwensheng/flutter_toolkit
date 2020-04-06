import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_toolkit/common/change_log.dart';
import 'package:flutter_toolkit/common/constant.dart';
import 'package:flutter_toolkit/common/envirpath.dart';
import 'package:flutter_toolkit/main.dart';
import 'package:flutter_toolkit/module/permission_check.dart';
import 'package:flutter_toolkit/utils/process.dart';
import 'package:flutter_toolkit/widgets/custom_dialog.dart';
import 'package:flutter_toolkit/widgets/public_widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'global_function.dart';
import 'info.dart';
import 'platform_channel.dart';

getStorageDirectory() async {
  if (Platform.isAndroid)
    documentsDir ??= (await getExternalStorageDirectory())
        .path
        .replaceAll("/Android/data/com.nightmare/files", ""); //初始化外部储存的路径
  else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    documentsDir = "${FileSystemEntity.parentOf(Platform.resolvedExecutable)}";
  } else if (Platform.isWindows) {}
}

envirInit() async {
  //检查环境
  await getStorageDirectory();
  if (Platform.isAndroid)
    CustomProcess.exec(
        "export PATH=/data/data/com.nightmare/files/usr/bin:\$PATH\n"); //更新环境变量
  List<String> path = [];
  if (Platform.isAndroid) {
    path = [
      "/data/data/com.nightmare/files/home",
      "/data/data/com.nightmare/files/usr",
      "/data/data/com.nightmare/files/MToolkit",
      "/data/data/com.nightmare/files/Apktool",
      "/data/data/com.nightmare/files/Apktool/Framework",
      "/data/data/com.nightmare/files/usr/bin",
      "/data/data/com.nightmare/files/usr/tmp",
      "$documentsDir/MToolkit",
      "$documentsDir/MToolkit/Rom",
      "$documentsDir/MToolkit/日志文件夹",
    ]; //一些需要被创建的文件夹
  } else {
    path = [
      "$documentsDir/MToolkit/日志文件夹",
      "${FileSystemEntity.parentOf(Platform.resolvedExecutable)}/MToolkit",
      "${FileSystemEntity.parentOf(Platform.resolvedExecutable)}/MToolkit/Rom",
    ]; //一些需要被创建的文件夹
  }
  try {
    if (Platform.isAndroid) {
      File("${EnvirPath.binPath}/apktool")
          .writeAsStringSync("echo apktoolFunc \"\$@\"");
      File("${EnvirPath.binPath}/baksmali")
          .writeAsStringSync("echo baksmaliFunc \"\$@\"");
      File("${EnvirPath.binPath}/smali")
          .writeAsStringSync("echo smaliFunc \"\$@\"");
    } else {
      File("${EnvirPath.binPath}/apktool").writeAsStringSync(
          "java -Xmx800m -jar ${EnvirPath.binPath}/apktool.jar \"\$@\"");
      File("${EnvirPath.binPath}/baksmali").writeAsStringSync(
          "java -Xmx800m -jar ${EnvirPath.binPath}/baksmali-2.2.7.jar \"\$@\"");
      File("${EnvirPath.binPath}/smali").writeAsStringSync(
          "java -Xmx800m -jar ${EnvirPath.binPath}/smali-2.2.7.jar \"\$@\"");
    }
  } catch (e) {}
  CustomProcess.exec("chmod 777 ${EnvirPath.binPath}/apktool");
  CustomProcess.exec("chmod 777 ${EnvirPath.binPath}/baksmali");
  CustomProcess.exec("chmod 777 ${EnvirPath.binPath}/smali");
  for (String str in path) {
    if (!Directory(str).existsSync())
      Directory(str).createSync(recursive: true); //循环创建工作文件夹
  }
  if (Platform.isAndroid) {
    if (!File(EnvirPath.busyboxPath).existsSync()) {
      //如果没有发现/system/xbin或者数据目录下有buysbox
      ByteData byteData = await rootBundle.load('busybox');
      Uint8List picBytes =
          byteData.buffer.asUint8List(); //以上两行是从apk内assets文件夹讲文件转换为Uint8List的轮子
      await File("/data/data/com.nightmare/files/usr/bin/busybox")
          .writeAsBytes(picBytes);
      //下面代码不能换成CustomProcess
      await Process.run("sh", [
        "-c",
        "chmod 777 /data/data/com.nightmare/files/usr/bin/busybox\n" + //更改busybox为可执行
            "/data/data/com.nightmare/files/usr/bin/busybox " +
            "--install -s /data/data/com.nightmare/files/usr/bin/\n"
      ]);
    }
    if (!Directory("/data/data/com.nightmare/files/Nightmare").existsSync()) {
      await PlatformChannel.Root.invokeMethod("Unzip");
    }
    CustomProcess.exec(
        "ln -s /system/bin/sh /data/data/com.nightmare/files/usr/bin\n"); //覆盖
  }
}

Future checkPermission(BuildContext context) async {
  //是否获取储存权限权限
  bool permission = await PlatformChannel.Root.invokeMethod("Permission_Check");
  print(permission);
  if (!permission) {
    //如果没有就申请
    showCustomDialog2(
      context: context,
      height: 120,
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: FullHeightListView(
          child: PermissionCheck(
            nextCheck: () {
              Navigator.pop(context);
              checkAgreement(context);
            },
          ),
        ),
      ),
    );
  } else
    checkAgreement(context);
}

checkAgreement(BuildContext context) async {
  bool isAgree = Info.getValue("Agreement") == "true";
  if (!isAgree) {
    showCustomDialog(
        context,
        const Duration(milliseconds: 300),
        400,
        WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: FullHeightListView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    "声明",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "    MToolkit是为玩机爱好者打造的便捷工具，如您不清楚如何刷机，对ROOT没有任何了解请勿使用本软件工具箱中的功能，根据反馈修改系统核心组件时软件会自动备份，请自行再做好必要的备份工作，部分功能也并不是不放出来，那些功能除了依赖工具箱还依赖大量的反编译资源",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        PlatformChannel.Drawer.invokeMethod("Exit");
                      },
                      child: Text(
                        "退出",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Info.setValue("Agreement", true);
                        Navigator.of(context).pop();
                        checkAgreement(context);
                      },
                      child: Text(
                        "知道了",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        false);
  } else
    checkisUpdate(context);
}

checkisUpdate(BuildContext context) async {
  if (Info.getValue("VERSION_KEY") == "") {
    Info.setValue("VERSION_KEY", "0");
  }
  int lastVersion = int.parse(Info.getValue("VERSION_KEY"));
  int currentVersion = Constant.versionCode;
  if (currentVersion > lastVersion) {
    showUpdateLog(context);
  }
}

showUpdateLog(BuildContext context) async {
  showCustomDialog(
      context,
      const Duration(milliseconds: 400),
      600,
      WillPopScope(
        onWillPop: () async {
          int currentVersion = Constant.versionCode;
          Info.setValue('VERSION_KEY', currentVersion);
          Navigator.of(context).pop();
          return false;
        },
        child: Stack(
          children: <Widget>[
            changeLog(changeLogText, false),
            Align(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                child: Text(
                  '不再显示',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  int currentVersion = Constant.versionCode;
                  Info.setValue('VERSION_KEY', currentVersion);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
        // child: Column(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: <Widget>[
        //       versionlog(byteData),
        //       Align(
        //         alignment: Alignment.centerRight,
        //         child: FlatButton(
        //           child: Text(
        //             '不再显示',
        //             style: TextStyle(
        //               fontSize: 14.0,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //           onPressed: () async {
        //             SharedPreferences prefs =
        //                 await SharedPreferences.getInstance();
        //             int currentVersion = Nightmare.versionCode;
        //             prefs.setInt('VERSION_KEY', currentVersion);
        //             Navigator.of(context).pop();
        //           },
        //         ),
        //       )
        //     ],
        //   ),
      ),
      false);
}

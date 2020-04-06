library function;

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toolkit/common/constant.dart';
import 'package:flutter_toolkit/common/serivce_url.dart';
import 'package:flutter_toolkit/model/toolkit_info.dart';
import 'package:flutter_toolkit/module/assets_install_page.dart';
import 'package:flutter_toolkit/utils/process.dart';
import 'package:flutter_toolkit/utils/show_toast.dart';
import 'package:flutter_toolkit/widgets/custom_dialog.dart';
import 'package:flutter_toolkit/widgets/public_widgets.dart';
import '../main.dart';
import 'info.dart';
import 'platform_channel.dart';
export 'show_toast.dart';
export 'get_file_size.dart';


bool globalPopBool = false; //全局的返回布尔值
bool onWillPop() {
  showToast(context: globalContext, message: "再按一次退出软件");
  Future.delayed(Duration(milliseconds: 200), () {
    globalPopBool = true;
    print(globalPopBool);
  });
  return globalPopBool;
}

needUpdateBinary(BuildContext context, bool bval, List<int> _int) async {
  Future.delayed(
    Duration(milliseconds: 100),
    () {
      if (!bval) {
        showToast(context: context, message: "工具资源残缺，请自行安装红色字体资源");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (c) {
              return AssetsInstall(
                bright: _int,
              );
            },
          ),
        );
      }
    },
  );
}

void showNeedRootToast() => showToast2("需要ROOT权限!");

//需要ROOT的弹窗

Future<String> execShell(bool needRoot, String cmd) async {
  //用这个代码更简洁
  return await CustomProcess.exec(cmd);
}

bool checkHasMagisk() {
  bool hasMagisk = Directory("/sbin/.magisk/img/MToolkit").existsSync();
  return hasMagisk;
}

//获取App跟名字的一个map
// getmap() async {
//   String allapp =
//       (await CustomProcess.exec("", "pm list package\n"))
//           .toString()
//           .replaceAll(RegExp("package:"), ""); //拿到所有的安装包生成List
//   String appname = await PlatformChannel.AppInfo.invokeMethod(allapp);
//   documentsDir ??= (await getExternalStorageDirectory())
//       .path
//       .replaceAll("/Android/data/com.nightmare/files", ""); //初始化外部储存的路径
//   Directory(documentsDir + "/.icon").createSync(); //创建外部图标储存目录
//   yymap.clear(); //清除yymap
//   for (int i = 0; i < allapp.split("\n").length; i++) {
//     yymap.putIfAbsent(
//       allapp.split("\n")[i],
//       () => appname.split("\n")[i],
//     );
//   } //循环将package跟app名称一一对应生成map
//   getapp(); //获取应用软件
//   getsystem(); //获取系统软件
//   liebiao(() {}); //获取冻结列表
//   runapp(() {}); //获取正在运行软件
//   getdisable(() {}); //获取已经软件
// }

getDeviceDpiSize() async {
  //获取分辨率跟dpi
  String _size = await execShell(ToolkitInfo.isRoot, "wm size");
  String _dpi = await execShell(ToolkitInfo.isRoot, "wm density");
  _dpi = _dpi.contains("Override")
      ? _dpi.replaceAll(RegExp("Physical density.*|Override density: "), "")
      : _dpi.replaceAll(RegExp("Physical density: "), "");
  _size = _size.contains("Override")
      ? _size.replaceAll(RegExp("Physical size.*|Override size: "), "")
      : _size.replaceAll(RegExp("Physical size: "), "");
  if (_size.isNotEmpty) {
    physicalSize = Offset(
        double.parse(_size.split("x")[0]), double.parse(_size.split("x")[1]));
  }
  deviceDPI = int.parse(_dpi);
}

useanima(int value, Function fun) async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // if (value == 1) animabval = true;
  // if (value == 0) animabval = false;
  // if (value != -1) prefs.setBool("Animation", animabval);
  // if (prefs.getBool("Animation") == null) {
  //   prefs.setBool("Animation", true);
  // }
  // if (prefs.getBool('Animation')) {
  //   animabval = true;
  // } else {
  //   animabval = false;
  // }
  // fun();
}

// runapp(Function fun) async {
//   //runlist = [];
//   //运行中的程序
//   String b = (await CustomProcess.exec("", "ps -ef\n"))
//       .toString()
//       .replaceAll(RegExp("root.*|system.*"), "");
//   List<String> _list = [];
//   for (String _str in yymap.keys.toList()) {
//     if (b.split("\n").toSet().join().contains(_str)) _list.add(_str);
//   }
//   runlist = _list;
//   fun();
// }

// getdisable(Function fun) async {
//   dislist =
//       (await CustomProcess.exec("", "pm list package -d\n"))
//           .toString()
//           .replaceAll(RegExp("package:"), "")
//           .split("\n");
//   fun();
// }



// getsystem() async {
//   //拿到系统软件List
//   syylist =
//       (await CustomProcess.exec("", "pm list package -s\n"))
//           .toString()
//           .replaceAll(RegExp("package:"), "")
//           .split("\n");
//   syynlist = [];
//   for (String _str in syylist) {
//     syynlist.add(yymap[_str]);
//   }
//   // if (eventBus != null) eventBus.fire(YingYong());
// }

romer(Function fun) async {
  ToolkitInfo.isRoot ??= true;
}

// Future liebiao(Function fun, [bool bval]) async {
//   Directory documentsDir = await getExternalStorageDirectory();
//   String documentsPath = documentsDir.path + "/MX";
//   String file =
//       await CustomProcess.exec("", "cat $documentsPath/冻结列表");
//   djlist = file.isEmpty ? [] : file.split("\n");
//   djlist = djlist.toSet().toList();
//   // if (eventBus != null && bval == null) eventBus.fire(YingYong());
//   fun();
// }

Future<bool> whetherUpdata() async {
  //这个只是根据sp数据判断用户是否选择不提示更新
  if (Info.getValue("UpdateDisable") == Constant.versionCode.toString()) {
    return false;
  } else
    return true;
}

Future<bool> hasNewVersion() async {
  Response response;
  Dio dio = new Dio();
  response = await dio.get("$fileurl/version");
  if (int.parse(response.data.toString()) > Constant.versionCode) {
    return true;
  } else
    return false;
}

updateApp() async {
  Dio dio = Dio();
  Response response;
  response = await dio.get("https://www.coolapk.com/apk/com.nightmare");
  Iterable<Match> match0 =
      RegExp("<div class=\"apk_left_title\">([\\s\\S]+?)</div>")
          .allMatches(response.data);
  String changeLog = "";
  for (Match _match in match0) {
    if (_match.group(0).contains("新版特性")) changeLog += _match.group(0);
  }
  changeLog = changeLog.replaceAll("<br />", "");
  changeLog = changeLog.replaceFirst(RegExp(".*([\\s\\S]+?)-"), "-");
  changeLog = changeLog.replaceAll(RegExp("<.*"), "").trim();
  showCustomDialog(
      globalContext,
      const Duration(milliseconds: 200),
      100,
      FullHeightListView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              child: Text(
                "新版特性",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              changeLog,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    "该版本不再提示",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    Info.setValue("UpdateDisable", Constant.versionCode);
                    // await prefs.setInt('Update', Nightmare.versionCode + 1);
                    Navigator.of(globalContext).pop();
                  },
                ),
                FlatButton(
                  child: Text(
                    "更新",
                    style: TextStyle(
                      // fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    PlatformChannel.JuanZheng.invokeMethod(
                        "https://www.coolapk.com/apk/com.nightmare");
                  },
                ),
              ],
            )
          ],
        ),
      ),
      true);
}

forceExit() async {
  Response response;
  Dio dio = new Dio();
  response = await dio.get("$fileurl/MToolkit");
  if (response.data.split("\n").contains("${Constant.versionCode}")) {
    await PlatformChannel.Toast.invokeMethod(
        "该版本已禁止使用,3秒后自动退出，请勿再次打开该版本，否则后果自负！", {"time": 1});
    Future.delayed(Duration(seconds: 3), () {
      PlatformChannel.Drawer.invokeMethod("Exit");
    });
  }
}

showCustomDialog2<T>(
    {Duration duration = const Duration(milliseconds: 300),
    double height = 0.0,
    @required Widget child,
    bool bval = true,
    bool isPadding = true,
    BuildContext context,
    String tag}) {
  // print(tag);
  //if (tag == null) tag = "dialog";
  return showDialog<T>(
    useRootNavigator:false,
    context: context ?? globalContext,
    barrierDismissible: bval, // user must tap button!
    builder: (BuildContext c) {
      return DialogBuilder(
        tag: tag,
        isPadding: isPadding,
        duration: duration,
        height: height,
        child: Theme(data: Theme.of(context ?? globalContext), child: child),
        actions: <Widget>[],
      );
    },
  );
}

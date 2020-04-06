import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_toolkit/common/envirpath.dart';
import 'package:flutter_toolkit/common/serivce_url.dart';
import 'package:flutter_toolkit/main.dart';
import 'package:flutter_toolkit/common/toolkit_colors.dart';
import 'package:flutter_toolkit/provider/change_notifier.dart';
import 'package:flutter_toolkit/utils/assets_func.dart';
import 'package:flutter_toolkit/utils/global_function.dart';
import 'package:flutter_toolkit/utils/platform_channel.dart';
import 'package:flutter_toolkit/utils/root_check.dart';
import 'package:provider/provider.dart';

class Assetsbool {
  List<dynamic> boolList;
  Assetsbool({this.boolList});
}

class AssetsInstall extends StatefulWidget {
  final List<int> bright; //需要高亮的index列表
  final String tag;
  static List<String> assetsPaths = [
    //各个包的主要文件路径
    "${EnvirPath.binPath}/zip",
    "/data/data/com.nightmare/files/Nightmare/Animation",
    "${EnvirPath.busyboxPath}",
    "/system/usr/Nightmare/Backup",
    "/sbin/.magisk/img/MToolkit",
    "${EnvirPath.binPath}/python",
    "${EnvirPath.binPath}/gcc",
    "${EnvirPath.binPath}/romtool",
    "${EnvirPath.binPath}/7z",
    "${EnvirPath.binPath}/brotli",
    "${EnvirPath.binPath}/update-binary",
    "/data/data/com.nightmare/files/home/AIK-mobile",
    "${EnvirPath.binPath}/magiskboot",
    "/data/data/com.nightmare/files/Apktool/aapt",
    "/data/data/com.nightmare/files/Apktool/Framework/1.apk",
    "${EnvirPath.binPath}/ssh",
    "${EnvirPath.binPath}/adb",
    "${EnvirPath.binPath}/extract_android_ota_payload",
    "${EnvirPath.binPath}/zipalign",
  ];

  static List<String> link = [
    //下载的链接列表
    "$fileurl/Zip.zip",
    "$fileurl/Animation.zip",
    "/data/data/com.nightmare/files/usr/bin/busybox",
    "$fileurl/system/usr/Nightmare/Backup",
    "$fileurl/Rom/MToolkit.zip",
    "$fileurl/Python.zip",
    "$fileurl/libllvm.zip",
    "$fileurl/Romtool.zip",
    "$fileurl/p7zip.zip",
    "$fileurl/Brotli.zip",
    "$fileurl/update-binary.zip",
    "$fileurl/AIK-mobile.zip",
    "$fileurl/Rom/MagiskBoot.zip",
    "$fileurl/aapt.zip",
    "$fileurl/Framework.zip",
    "$fileurl/Openssh.zip",
    "$fileurl/Adb/Adb.zip",
    "$fileurl/Rom/extract_android_ota_payload.zip",
    "$fileurl/Rom/zipalign.zip"
  ];
  static List<String> itemName = [
    '压缩插件',
    '过度动画资源',
    'Busybox',
    '通用备份单刷包（暂无）',
    'MToolkit面具框架',
    "Python环境  ",
    'GCC(C语言编译环境)',
    'ROM处理工具',
    '7zip(解压img文件)',
    'Brotli(*.br=>*.dat转换工具)',
    'update-binary(刷机二进制)',
    'boot处理工具',
    'avb补丁(去除boot中avb需要组件)',
    'aapt(apktool配套工具)',
    '基础框架(apktool配套工具)',
    'Openssh',
    'Adb+Fastboot(远程控制，刷机)',
    'Payload.bin解压',
    'ZipAlign对齐工具',
  ];

  static bool checkAll(List<int> assetsList) {
    bool allBool = true;
    for (int i in assetsList) {
      allBool = allBool &&
          (File(assetsPaths[i - 1]).existsSync() ||
              Directory(assetsPaths[i - 1]).existsSync());
    }
    return allBool;
  }

  const AssetsInstall({Key key, this.bright, this.tag}) : super(key: key);

  @override
  _AssetsInstallState createState() => _AssetsInstallState();
}

class _AssetsInstallState extends State<AssetsInstall> {
  Assetsbool _assetsbool;

  @override
  void initState() {
    super.initState();
    List<bool> _boolList = [];
    for (int i = 0; i <= AssetsInstall.assetsPaths.length; i++) {
      _boolList.add(null);
    }
    _assetsbool = Assetsbool(boolList: _boolList);
    check();
    // Process.runSync("su", []);
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  double thisWidgetWidth = 0.0;
  void _onAfterRendering(Duration timeStamp) async {
    thisWidgetWidth = context.size.width;
  }

  check() async {
    for (int i = 0; i < AssetsInstall.assetsPaths.length; i++) {
      await checkfile(i);
    }
    _assetsbool.boolList[2] = hasBusyBox();
    if (mounted) setState(() {});
  }

  Future<bool> checkfile(int index) async {
    await Future.delayed(
      Duration(milliseconds: 100),
      () {
        if (FileSystemEntity.isDirectorySync(AssetsInstall.assetsPaths[index]))
          _assetsbool.boolList[index] =
              Directory(AssetsInstall.assetsPaths[index]).existsSync();
        else
          _assetsbool.boolList[index] =
              File(AssetsInstall.assetsPaths[index]).existsSync() ||
                  FileSystemEntity.isLinkSync(
                    AssetsInstall.assetsPaths[index],
                  );
      },
    );
    if (mounted) setState(() {});
    return _assetsbool.boolList[index];
  }

  List<int> downloadIndexs = []; //正在下载的index列表

  Map<int, double> downloadpercents = Map(); //下载进度
  download(int _index, int _fullByte) async {
    _assetsbool.boolList[_index - 1] = null; //让那个加载动画转起来
    setState(() {});
    showToast(context: context, message: "下载已经开始，请等待下载完成");
    Navigator.of(context).pop();
    downloadIndexs.add(_index); //
    Dio _dio = Dio();
    String _filePath =
        "/data/data/com.nightmare/files/home/${AssetsInstall.link[_index - 1].replaceAll(RegExp(".*/"), "")}";
    _dio.download(AssetsInstall.link[_index - 1], _filePath).whenComplete(
      () {
        downloadIndexs.remove(_index);
      },
    );
    while (downloadIndexs.contains(_index)) {
      await Future.delayed(Duration(milliseconds: 200), () {});
      if (File(_filePath).existsSync())
        downloadpercents[_index] = File(_filePath).lengthSync() / _fullByte;
      setState(() {});
    }
    showToast(
        context: context, message: "${AssetsInstall.itemName[_index - 1]}安装中");
    ProcessResult result = await Process.run(
      "sh",
      [
        "-c",
        "export PATH=/data/data/com.nightmare/files/usr/bin:\$PATH\n" +
        "mkdir /data/data/com.nightmare/files/home/$_index\n" +
        "busybox unzip -o $_filePath -d /data/data/com.nightmare/files/home/$_index\n" +
        "cd /data/data/com.nightmare/files/home/$_index\n" +
        "sh /data/data/com.nightmare/files/home/$_index/install.sh\n" +
        "rm -rf /data/data/com.nightmare/files/home/$_index\n" +
        "rm -rf $_filePath\n"
      ],
      // environment: {"PATH": "/data/data/com.nightmare/files/usr/bin"},
      // runInShell: true,
      includeParentEnvironment: true,
    );
    File("$documentsDir/MToolkit/日志文件夹/资源安装完整日志.txt")
        .writeAsStringSync(result.stdout + "\n\n\n\n" + result.stderr);

    if (await checkfile(_index - 1))
      PlatformChannel.Toast.invokeMethod(
          "${AssetsInstall.itemName[_index - 1]}安装成功");
    else
      PlatformChannel.Toast.invokeMethod(
          "${AssetsInstall.itemName[_index - 1]}安装失败");
  }

  Widget assets(int _int, String str, dynamic bval) {
    Color _color = Theme.of(context).textTheme.body1.color;
    if (bval != null &&
        widget.bright != null) if (widget.bright.contains(_int) && !bval)
      _color = Color(0xffff0000);
    return InkWell(
      onTap: () {
        downloadDialog(
          context,
          AssetsInstall.link[_int - 1],
          fun: (fullByte) {
            download(_int, fullByte);
          },
        );
      },
      child: SizedBox(
        height: 36.0,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Divider(
                height: 1.0,
                indent: 24.0,
                endIndent: 24.0,
              ),
            ),
            downloadIndexs.contains(_int)
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: thisWidgetWidth,
                      height: 2.0,
                      child: Padding(
                        padding: EdgeInsets.only(left: 2.0, right: 2.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: LinearProgressIndicator(
                            value: downloadpercents[_int],
                            backgroundColor: Colors.grey,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                MToolkitColors.appColor),
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    width: 0,
                  ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    str,
                    style: TextStyle(color: _color),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  bval == null
                      ? Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: SpinKitThreeBounce(
                            color: MToolkitColors.appColor,
                            size: 16.0,
                          ),
                        )
                      : bval
                          ? SizedBox(
                              height: 20,
                              child: Icon(
                                Icons.check,
                                size: 20,
                              ),
                            )
                          : Row(
                              children: <Widget>[
                                SizedBox(
                                  height: 20,
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MToolKitNotifier mToolKitNotifier = Provider.of<MToolKitNotifier>(context);
    return Theme(
      data: ThemeData(
        fontFamily: Platform.isLinux ? "NotoSansCJK-Regular" : null,
        textTheme: TextTheme(
          body1: TextStyle(
            color: isDarkMode ? Color(0xb3ffffff) : mToolKitNotifier.fontsColor,
          ),
        ),
        primaryColorBrightness: Brightness.light,
        backgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: isDarkMode ? Color(0xb3ffffff) : MToolkitColors.fontsColor,
          ),
          textTheme: TextTheme(
            title: TextStyle(
              color: isDarkMode ? Color(0xb3ffffff) : MToolkitColors.fontsColor,
              fontSize: 18.0,
            ),
          ),
          color: isDarkMode ? Color(0xff303030) : Color(0xfffafafa),
        ),
        scaffoldBackgroundColor:
            isDarkMode ? Color(0xff303030) : Color(0xfffafafa),
      ),
      child: Scaffold(
        appBar: PreferredSize(
          child: Padding(
            padding: EdgeInsets.only(left: 0.0, right: 0.0),
            child: AppBar(
              leading: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: DecoratedBox(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(25)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24.0,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
              title: Text("资源管理器"),
              elevation: 0.0,
              actions: <Widget>[],
            ),
          ),
          preferredSize: Size(MediaQuery.of(context).size.width, 60),
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 20.0),
                itemCount: AssetsInstall.itemName.length,
                itemBuilder: (c, index) {
                  return assets(
                      index + 1,
                      '${index + 1}.${AssetsInstall.itemName[index]}',
                      _assetsbool.boolList[index]);
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "tips:点击即可下载资源",
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_toolkit/provider/change_notifier.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import 'common/envirpath.dart';
import 'module/drawer/drawer.dart';
import 'package:flutter_toolkit/common/toolkit_colors.dart';
import 'module/file_manager/file_manager.dart';
import 'module/file_manager/page/video.dart';
import 'module/file_manager/provider/file_manager_notifier.dart';
import 'module/term/term.dart';
import 'router/ripple_router.dart';
import 'utils/global_function.dart';
import 'utils/info.dart';
import 'utils/init_app.dart';
import 'utils/native.dart';
import 'utils/process.dart';
import 'utils/root_check.dart';

String model; //机型
bool usemagisk = false; //是否使用面具模块的字符串
String documentsDir; //安卓外部储存
bool animabval = true; //是否使用动画
Map userMessage = Map<String, dynamic>(); //用户的信息
Offset physicalSize = Offset(0, 0); //设备备的分辨率
int deviceDPI = 0; //设备的DPI，不能用dart的获取，dart不会跟随系统的改变
BuildContext globalContext; //全局的Context
BuildContext pushContext; //全局的Context
bool isDarkMode = false;
initMain() async {
  // print(await getLibPath("com.nightmare"));
  await CustomProcess.init();
  if (Platform.isAndroid)
    await CustomProcess.exec(
        "export PATH=/data/data/com.nightmare/files/usr/bin:\$PATH\nsu\n");
  romer(() {});

  if (await rootCheck()) {
    //当设备获取root后去判断该版本是否可用
    forceExit(); //是否退出
  } else {
    showToast2("未获取到Root权限");
  }
  bool canUpdate = await whetherUpdata();
  if (canUpdate) {
    if (await hasNewVersion()) {
      updateApp();
    }
  }
  envirInit();
}

void main() {
  initMain();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  // isDarkMode = false;
  // print(Platform.resolvedExecutable);
  if (!Platform.isAndroid) {
    EnvirPath.filesPath =
        "${FileSystemEntity.parentOf(Platform.resolvedExecutable)}/data";
    EnvirPath.binPath = EnvirPath.filesPath + "/usr/bin";
    EnvirPath.tmpPath = EnvirPath.filesPath + "/usr/tmp";
  }
  print("Platform.script====>${Platform.script}");
  // print(EnvirPath.filesPath);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => MToolKitNotifier(),
      ),
      ChangeNotifierProvider(
        create: (_) => HomePageNotifier(),
      ),
      ChangeNotifierProvider(
        create: (_) => FiMaPageNotifier(),
      ),
    ],
    child: MToolKit(),
  ));
}

class MToolKit extends StatefulWidget {
  @override
  _MToolKitState createState() => _MToolKitState();
}

class _MToolKitState extends State<MToolKit>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    
    Native.test();
    print(Platform.isWindows);
    if (!Platform.isWindows) Niterm.creatNewTerm(); //创建一个虚拟终端
    Future.delayed(Duration(milliseconds: 1000), () {
      if (Platform.isAndroid) checkPermission(globalContext);
    });
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  Future<void> _onAfterRendering(Duration timeStamp) async {
    // initMode(context);
    // Scaffold.of(context).openDrawer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Future<Uint8List> _capturePng(GlobalKey globalKey) async {
  //   print("执行");
  //   RenderRepaintBoundary boundary =
  //       globalKey.currentContext.findRenderObject();
  //   ui.Image image =
  //       await boundary.toImage(pixelRatio: window.devicePixelRatio);
  //   ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List picBytes = byteData.buffer.asUint8List();
  //   return picBytes;
  // }

  GlobalKey rootWidgetKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    // print(4.toRadixString(2));
    // print(56.toRadixString(2));
    // print((4<<8).toRadixString(2));
    // print((4<<8)|56);
    // rootCheck();
    // Native.init();
    Color fontsColor = isDarkMode ? Colors.white70 : Color(0xff4b5c76);
    Provider.of<MToolKitNotifier>(context);
    window.onPlatformBrightnessChanged = () {
      MToolKitNotifier mToolKitNotifier =
          Provider.of<MToolKitNotifier>(context);
      var _homePageNotifier = Provider.of<HomePageNotifier>(context);
      Navigator.of(pushContext).pushReplacementNamed(
        _homePageNotifier.currentRoute,
      );
      if (window.platformBrightness==Brightness.dark) {
        Info.setValue("ThemeMode", "Dark");
        Future.delayed(Duration(milliseconds: 1100), () {
          mToolKitNotifier.changeMode(ThemeMode.dark);
        });
        // mToolKitNotifier
        //     .changeBright(Brightness.dark);
      } else {
        Info.setValue("ThemeMode", "Light");
        Future.delayed(Duration(milliseconds: 1000), () {
          mToolKitNotifier.changeMode(ThemeMode.light);
        });
        // mToolKitNotifier
        //     .changeBright(Brightness.light);
      }
    };
    return MaterialApp(
        title: "MTOOLKIT",
        //showPerformanceOverlay: true,//性能树
        //debugShowMaterialGrid: true,//右上角那个debug
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: Platform.isLinux ? "NotoSansCJK-Regular" : null,
            textTheme: TextTheme(
              body1: TextStyle(color: fontsColor),
              button: TextStyle(color: fontsColor),
            ),
            brightness: Brightness.light,
            accentColorBrightness: Brightness.light,
            accentTextTheme: TextTheme(
              body1: TextStyle(color: fontsColor),
              button: TextStyle(color: fontsColor),
            ),
            buttonTheme: Theme.of(context).buttonTheme.copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: fontsColor,
                      ),
                  textTheme: ButtonTextTheme.normal,
                  buttonColor: Colors.black,
                  highlightColor: Color(0x66bcbcbc),
                  splashColor: Color(0x66bcbcbc),
                ),
            accentColor: MToolkitColors.appColor,
            cardColor: Colors.white),
        home: RepaintBoundary(
          key: rootWidgetKey,
          child: Builder(
            builder: (context) {
              // Future.delayed(Duration(seconds: 2), () async {
              //   Uint8List _aa = await _capturePng(rootWidgetKey);
              //       File("${documentsDir}/MToolkit/截图/04.png")
              //           .writeAsBytesSync(_aa);
              //            showToast2("保存成功");
              // });

              globalContext = context;
              return Scaffold(
                // floatingActionButton: FloatingActionButton(
                //   child: Text("保存"),
                //   onPressed: () async {
                //     Uint8List _aa = await _capturePng(rootWidgetKey);
                //     File("${documentsDir}/MToolkit/截图/01.png")
                //         .writeAsBytesSync(_aa);
                //     showToast2("保存成功");
                //   },
                // ),
                backgroundColor: Color(0xfffafafa),
                drawer: MainDrawer(),
                body: Builder(
                  builder: (context) {
                    return HomePage();
                  },
                ),
              );
            },
          ),
        ));
  }
}

class FileImageEx extends FileImage {
  int fileSize;
  FileImageEx(File file, {double scale = 1.0})
      : assert(file != null),
        assert(scale != null),
        super(file, scale: scale) {
    fileSize = file.lengthSync();
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final FileImageEx typedOther = other;
    return file?.path == typedOther.file?.path &&
        scale == typedOther.scale &&
        fileSize == typedOther.fileSize;
  }

  @override
  int get hashCode => hashValues(file?.path, scale);
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    isDarkMode = Info.getValue("ThemeMode") == "Dark";
    String value = Info.getValue("首页");
    String initRoutrName = value == "" ? "文件管理器" : value;
    HomePageNotifier homePageNotifier = Provider.of<HomePageNotifier>(context);
    if (homePageNotifier.currentRoute == "") {
      homePageNotifier.setCurrentRoute(initRoutrName);
      // print(object)
    }

    return Navigator(
      initialRoute: initRoutrName,
      onGenerateRoute: (RouteSettings settings) {
        Widget child;
        switch (settings.name) {
          case '文件管理器':
            child = FileManager();
            break;
         
          default:
            child = FileManager();
            break;
        }
        return RippleRoute(
          Builder(
            builder: (c) {
              pushContext = c;
              return child;
            },
          ),
          RouteConfig.fromSize(
            Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
          ),
        );
      },
    );
  }
}

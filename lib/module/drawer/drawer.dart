import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_toolkit/common/constant.dart';
import 'package:flutter_toolkit/main.dart';
import 'package:flutter_toolkit/model/toolkit_info.dart';
import 'package:flutter_toolkit/common/toolkit_colors.dart';
import 'package:flutter_toolkit/provider/change_notifier.dart';
import 'package:flutter_toolkit/utils/info.dart';
import 'package:provider/provider.dart';
import 'drawer_list.dart';
import 'drawer_logo.dart';
import 'header_animation.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  void initState() {
    super.initState();
    // initMode();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  void _onAfterRendering(Duration timeStamp) {
    // mToolKitNotifier.changeBright(Brightness.light);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double drawerWidth;
    if (Platform.isAndroid) {
      drawerWidth = MediaQuery.of(context).size.width * 3 / 4;
    } else {
      drawerWidth = 300.0;
    }
    Color fontsColor = isDarkMode ? Colors.white70 : Color(0xff4b5c76);
    Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    // customLog(this,"sd");
    return Theme(
        data: ThemeData(
            fontFamily: Platform.isLinux ? "NotoSansCJK-Regular" : null,
            dialogBackgroundColor: isDarkMode ? Colors.black : Colors.white,
            textTheme: TextTheme(
              // TextField输入文字颜色
              // Text默认文字样式
              body1: TextStyle(color: fontsColor),
              subhead: TextStyle(color: fontsColor),
              // 这里用于小文字样式
              // subtitle: isDarkMode ? TextStyles.textDarkGray12 : TextStyles.textGray12,
            ),
            buttonTheme: Theme.of(context).buttonTheme.copyWith(
                  highlightColor: Color(0x66bcbcbc),
                  splashColor: Color(0x66bcbcbc),
                ),
            appBarTheme: AppBarTheme(
              color: Colors.transparent,
              iconTheme: IconThemeData(color: fontsColor),
              textTheme: TextTheme(
                title: TextStyle(
                  color: fontsColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            backgroundColor: backgroundColor,
            iconTheme: IconThemeData(color: fontsColor.withOpacity(0.6)),
            primaryColorBrightness:
                isDarkMode ? Brightness.dark : Brightness.light,
            brightness: Brightness.light,
            accentColorBrightness: Brightness.light,
            accentColor: MToolkitColors.appColor,
            primaryColor: MToolkitColors.appColor,
            splashColor: Color(0x66bcbcbc),
            highlightColor: Color(0x66bcbcbc)),
        child: WillPopScope(
            child: SizedBox(
              width: drawerWidth,
              child: Material(
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
                elevation: 8.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 150.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: DrawerLogo(),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  userMessage["username"] != null
                                      ? "当前账户:${userMessage["username"]}"
                                      : "当前未登录",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  ToolkitInfo.isRoot
                                      ? "成功获取ROOT权限"
                                      : "未获取ROOT权限",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                Text(
                                  "版本:${Constant.versionCode}",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(0.0),
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 150.0,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: <Widget>[
                            DrawerList(),
                            MediaQuery(
                              data: MediaQueryData(
                                  size: Size(drawerWidth,
                                      MediaQuery.of(context).size.height)),
                              child: HeaderAnimation(),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    "夜间模式",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    height: 36,
                                    width: 36,
                                    child: Builder(
                                      builder: (iconContext) {
                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: Tooltip(
                                            message: "点击切换主题",
                                            child: Icon(
                                              isDarkMode
                                                  ? Icons.brightness_7
                                                  : Icons.brightness_2,
                                              size: 25.0,
                                            ),
                                          ),
                                          onTap: () {
                                            MToolKitNotifier mToolKitNotifier =
                                                Provider.of<MToolKitNotifier>(
                                                    context);
                                            isDarkMode = !isDarkMode;
                                            var _homePageNotifier =
                                                Provider.of<HomePageNotifier>(
                                                    context);
                                            Navigator.of(context).pop();
                                            Navigator.of(pushContext)
                                                .pushReplacementNamed(
                                              _homePageNotifier.currentRoute,
                                            );
                                            if (isDarkMode) {
                                              Info.setValue(
                                                  "ThemeMode", "Dark");
                                              Future.delayed(
                                                  Duration(milliseconds: 1100),
                                                  () {
                                                mToolKitNotifier
                                                    .changeMode(ThemeMode.dark);
                                              });
                                              // mToolKitNotifier
                                              //     .changeBright(Brightness.dark);
                                            } else {
                                              Info.setValue(
                                                  "ThemeMode", "Light");
                                              Future.delayed(
                                                  Duration(milliseconds: 1000),
                                                  () {
                                                mToolKitNotifier.changeMode(
                                                    ThemeMode.light);
                                              });
                                              // mToolKitNotifier
                                              //     .changeBright(Brightness.light);
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onWillPop: () async {
              Navigator.of(context).pop();
              return false;
            }));
  }
}

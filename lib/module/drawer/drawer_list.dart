import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/octicons.dart';
import 'package:flutter_toolkit/common/change_log.dart';
import 'package:flutter_toolkit/module/about.dart';
import 'package:flutter_toolkit/module/donate.dart';
import 'package:flutter_toolkit/router/ripple_router.dart';
import 'package:flutter_toolkit/utils/global_function.dart';
import 'package:flutter_toolkit/utils/platform_channel.dart';
import 'package:flutter_toolkit/widgets/custom_dialog.dart';
import 'package:flutter_toolkit/widgets/public_widgets.dart';
import 'drawer_item.dart';
import 'drawer_widget.dart';
import 'open_source.dart';

class DrawerList extends StatefulWidget {
  final callback;

  const DrawerList({Key key, this.callback}) : super(key: key);
  @override
  _DrawerListState createState() => _DrawerListState();
}

class _DrawerListState extends State<DrawerList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(0.0),
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        SizedBox(
          height: 12.0,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 0.0),
          child: Text(
            "页面列表",
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
        ),
        if (Platform.isAndroid)
          DrawerItem(
            text: "常用功能",
            iconData: Icons.build,
            setState: () {
              setState(() {});
            },
          ),
        DrawerItem(
          text: "文件管理器",
          iconData: Octicons.getIconData("file-directory"),
          setState: () {
            setState(() {});
          },
        ),
        DrawerItem(
          text: "ROM工具",
          iconData: Icons.settings_backup_restore,
          setState: () {
            setState(() {});
          },
        ),
        DrawerItem(
          text: "远程控制",
          iconData: Icons.phone_android,
          setState: () {
            setState(() {});
          },
        ),
        DrawerItem(
          text: "NiTerm",
          iconData: Octicons.getIconData("terminal"),
          setState: () {
            setState(() {});
          },
        ),
        DrawerItem(
          text: "应用管理",
          iconData: Icons.apps,
          setState: () {
            setState(() {});
          },
        ),
        DrawerItem(
          text: "阴影截屏",
          iconData: Icons.content_cut,
          setState: () {
            setState(() {});
          },
        ),
        DrawerItem(
          text: "数据线刷机",
          iconData: Icons.system_update,
          setState: () {
            setState(() {});
          },
        ),
        DrawerItem(
          text: "NiSsh",
          iconData: Octicons.getIconData("terminal"),
          setState: () {
            setState(() {});
          },
        ),
        // drawerItem("MX框架", Icons.adb, 1),
        // drawerItem("应用管理器", Icons.apps, 3),
        // drawerItem("终端模拟器", Octicons.getIconData("terminal"), 4),
        // drawerItem("代码编辑器", Entypo.getIconData("code"), 6),
        // drawerItem("Xshelldroid+Scpdroid", Octicons.getIconData("x"), 9),
        Divider(
          height: 4.0,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 0.0),
          child: Text(
            "更多",
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
        ),

        Builder(builder: (textContext) {
          return itemMore(Icons.attach_money, "捐赠", () {
            Navigator.of(context).push(
              RippleRoute(Donate(), RouteConfig.fromContext(textContext)),
            );
          });
        }),

        itemMore(Icons.settings_ethernet, "开源许可", () async {
          showCustomDialog2(child: OpenSource(), context: context);
        }),
        itemMore(Icons.group_add, "加入交流群", () {
          PlatformChannel.JuanZheng.invokeMethod(
              "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=157404704&card_type=group&source=qrcode");
        }),
        itemMore(Icons.cached, "检查更新", () async {
          if (await hasNewVersion()) {
            //如果有新的版本
            updateApp();
          } else {
            showToast(context: context, message: "还没有更新");
          }
        }),
        Builder(builder: (textContext) {
          return itemMore(Icons.info, "软件关于", () {
            Navigator.of(context).push(
              RippleRoute(About(), RouteConfig.fromContext(textContext)),
            );
          });
        }),

        itemMore(
          Icons.help,
          "查看更新日志",
          () async {
            showCustomDialog(context, const Duration(milliseconds: 300), 620,
                changeLog(changeLogText, true), true);
          },
        ),
        // itemMore(Icons.share, "分享", () async {
        //   String appPath=(await CustomProcess.exec<String>("", "pm path com.nightmare")).replaceAll(RegExp(".*:"), "");
        //   //得到M工具箱的apk路径
        //   print(appPath);
        //   CustomProcess.exec<void>("", "cp -f $appPath $documentsDir/MTOOLKIT/M工具箱内测版.apk");
        //   PlatformChannel.Drawer.invokeMethod("Share","$documentsDir/MTOOLKIT/M工具箱内测版.apk");
        //   // Share.share(text)
        // }),
        itemMore(Icons.exit_to_app, "退出软件", () {
          PlatformChannel.Drawer.invokeMethod("Exit");
        }),
      ],
    );
  }
}

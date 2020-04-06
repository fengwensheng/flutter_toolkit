import 'package:flutter/material.dart';
import 'package:flutter_toolkit/common/toolkit_colors.dart';
import 'package:flutter_toolkit/utils/platform_channel.dart';
import 'package:flutter_toolkit/widgets/public_widgets.dart';

class OpenSource extends StatelessWidget {
  List<Widget> openSource = [];
  final Map<String, String> license = {
    "ADB & Fastboot for Android NDK":
        "Static ARM adb and fastboot binaries for Android built with the NDK",
    "Sdat2img":
        "Convert sparse Android data image (.dat) into filesystem ext4 image (.img)",
    "img2sdat":
        "Convert filesystem ext4 image (.img) into Android sparse data image (.dat)",
    "Smali":
        "smali/baksmali is an assembler/disassembler for the dex format used by dalvik, Android's Java VM implementation. The syntax is loosely based on Jasmin's/dedexer's syntax, and supports the full functionality of the dex format (annotations, debug info, line info, etc.)",
    "Apktool":
        "It is a tool for reverse engineering 3rd party, closed, binary Android apps. It can decode resources to nearly original form and rebuild them after making some modifications; it makes possible to debug smali code step by step. Also it makes working with app easier because of project-like files structure and automation of some repetitive tasks like building apk, etc.",
  };
  final List licenseurl = [
    "https://github.com/Magisk-Modules-Repo/adb-ndk",
    "https://github.com/xpirt/sdat2img",
    "https://github.com/xpirt/img2sdat",
    "https://github.com/JesusFreke/smali",
    "https://github.com/iBotPeaches/Apktool"
  ];
  @override
  Widget build(BuildContext context) {
    for (int index = 0; index < license.keys.length; index++) {
      openSource.add(
        Material(
          color: Colors.white,
          child: InkWell(
            highlightColor: Colors.transparent,
            onTap: () {
              PlatformChannel.JuanZheng.invokeMethod(licenseurl[index]);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(license.keys.elementAt(index) + ":"),
                Text(
                  license[license.keys.elementAt(index)],
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  licenseurl[index],
                  softWrap: true,
                  style: TextStyle(
                      color: MToolkitColors.appColor,
                      fontSize: 14.0,
                      decoration: TextDecoration.underline,
                      decorationColor: MToolkitColors.appColor,
                      decorationStyle: TextDecorationStyle.solid),
                ),
                SizedBox(
                  height: 10.0,
                )
              ],
            ),
          ),
        ),
      );
    }
    return FullHeightListView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
              Text(
                "开源许可信息",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] +
            openSource +
            [
              Material(
                color: Colors.white,
                child: InkWell(
                  child: SizedBox(
                    height: 46,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            height: 22,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: FlutterLogo()),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text(
                            "Flutter相关",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) {
                          return LicensePage();
                        },
                        transitionDuration: const Duration(milliseconds: 600),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: FadeTransition(
                              opacity: Tween(begin: 0.0, end: 1.0)
                                  .animate(animation),
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      '确定',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
      ),
    );
  }
}

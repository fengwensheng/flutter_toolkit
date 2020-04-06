import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_toolkit/common/toolkit_colors.dart';
import 'package:flutter_toolkit/utils/platform_channel.dart';


class PermissionCheck extends StatefulWidget {
  final Function nextCheck;

  const PermissionCheck({Key key, this.nextCheck}) : super(key: key);
  @override
  _PermissionCheckState createState() => _PermissionCheckState();
}

class _PermissionCheckState extends State<PermissionCheck> {
  bool isChecking = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text(
                "需要使用储存权限创建工作目录，软件承诺不会恶意更改任何非本软件涉及内容",
                style: TextStyle(
                    color: Color(0xff000000),
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
              ),
            )),
        isChecking
            ? SizedBox(
                height: 36.0,
                child: SpinKitThreeBounce(
                  color: MToolkitColors.appColor,
                  size: 16.0,
                ),
              )
            : FlatButton(
                onPressed: () async {
                  isChecking = true;
                  setState(() {});
                  PlatformChannel.Root.invokeMethod("EXTERNAL_STORAGE");
                  while (true) {
                    bool permission = await PlatformChannel.Root.invokeMethod(
                        "Permission_Check");
                    if (permission) break;
                    await Future.delayed(Duration(milliseconds: 100));
                  }
                  widget.nextCheck();
                  // fun();
                },
                child: Text(
                  "确定",
                  style: TextStyle(
                    color: Color(0xff000000),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ],
    );
  }
}

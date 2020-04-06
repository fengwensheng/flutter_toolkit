import 'package:flutter/material.dart';
import 'package:flutter_toolkit/provider/change_notifier.dart';
import 'package:flutter_toolkit/utils/platform_channel.dart';
import 'package:provider/provider.dart';

class Donate extends StatelessWidget {
  final VoidCallback callback;

  const Donate({Key key, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    MToolKitNotifier mToolKitNotifier = Provider.of<MToolKitNotifier>(context);
    return MaterialApp(
      theme: ThemeData(
        brightness: mToolKitNotifier.primaryColorBrightness,
        primaryColorBrightness: mToolKitNotifier.primaryColorBrightness,
        // accentColor: Color(0xff811016),
        primaryColor: mToolKitNotifier.backgroundColor,
        splashColor: Color(0x22811016),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("捐赠通道"),
          centerTitle: true,
          elevation: 0.0,
          leading: Align(
            alignment: Alignment.center,
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(25)),
              height: 36,
              width: 36,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                child: const Icon(Icons.arrow_back),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        body: WillPopScope(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "QQ:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: <Widget>[
                  Image.asset(
                    "images/QQ_qrcode.png",
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.width / 2,
                  ),
                  FlatButton(
                    color: Colors.black26,
                    child: Text("保存二维码"),
                    onPressed: () {},
                  )
                ],
              ),
              Text(
                "微信:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: <Widget>[
                  Image.asset(
                    "images/Wechat_qrcode.png",
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.width / 2,
                  ),
                  FlatButton(
                    color: Colors.black26,
                    child: Text("保存二维码"),
                    onPressed: () {},
                  )
                ],
              ),
              Text(
                "支付宝:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: <Widget>[
                  Image.asset(
                    "images/Alipay_qrcode.png",
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.width / 2,
                  ),
                  Column(
                    children: <Widget>[
                      FlatButton(
                        color: Colors.black26,
                        child: Text("保存二维码"),
                        onPressed: () {},
                      ),
                      FlatButton(
                        color: Colors.black26,
                        child: Text("直接唤起"),
                        onPressed: () {
                          PlatformChannel.JuanZheng.invokeMethod(
                              "alipayqr://platformapi/startapp?saId=10000007&qrcode=" +
                                  "https://qr.alipay.com/fkx03443m8h7hnf0e4zapeb");
                        },
                      )
                    ],
                  ),
                ],
              ),
              Text(
                "如果你认为我做的这些对你有一些帮助，欢迎给作者捐赠打赏，捐助数额随意，重在心意。作者在开发功能跟修复Bug的时候也会有更多的动力",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: <Widget>[
              //     FlatButton(
              //       child: Text(
              //         'QQ',
              //         style: TextStyle(
              //           fontSize: 14,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       onPressed: () {
              //         PlatformChannel.JuanZheng.invokeMethod(
              //             "alipayqr://platformapi/startapp?saId=10000007&qrcode=" +
              //                 "HTTPS://QR.ALIPAY.COM/FKX02850L1BSEYDOJNDZC9");
              //         Navigator.of(context).pop();
              //       },
              //     ),
              //     FlatButton(
              //       child: Text(
              //         '微信',
              //         style: TextStyle(
              //           fontSize: 14,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       onPressed: () {
              //         PlatformChannel.JuanZheng.invokeMethod("weixin://qr/%@"
              //             "wxp://f2f0cL0Iq0nsH40H2_TPY7_dG3eP8nkhNth3");
              //         Navigator.of(context).pop();
              //       },
              //     ),
              //     FlatButton(
              //       child: Text(
              //         '支付宝',
              //         style: TextStyle(
              //           fontSize: 14,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       onPressed: () {
              //         PlatformChannel.JuanZheng.invokeMethod(
              //             "alipayqr://platformapi/startapp?saId=10000007&qrcode=" +
              //                 "https://qr.alipay.com/fkx03443m8h7hnf0e4zapeb");
              //         Navigator.of(context).pop();
              //       },
              //     ),
              //   ],
              // ),
            ],
          ),
          onWillPop: () async {
            callback();
            return false;
          },
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_toolkit/provider/change_notifier.dart';
import 'package:flutter_toolkit/utils/platform_channel.dart';
import 'package:flutter_toolkit/widgets/anvil_effect/anvil_effect.dart';
import 'package:flutter_toolkit/widgets/my_canvas.dart';
import 'package:flutter_toolkit/widgets/rotated_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  EventBus eventBus = new EventBus();
  GlobalKey rootWidgetKey = GlobalKey();
  void onChange(val) {
    // if (val > 0) {
    //   PlatformChannel.Toast.invokeMethod("打开QQ中");
    //   Future.delayed(Duration(milliseconds: 1000), () {
    //     eventBus.fire(
    //       ExplosionWidget(),
    //     );
    //     PlatformChannel.JuanZheng.invokeMethod(
    //         "mqqwpa://im/chat?chat_type=wpa&uin=906262255");
    //   });
    // }
    // if (val < 0) {
    //   PlatformChannel.Toast.invokeMethod("拉取群链接中");
    //   Future.delayed(Duration(milliseconds: 1000), () {
    //     eventBus.fire(
    //       ExplosionWidget(),
    //     );
    //     PlatformChannel.JuanZheng.invokeMethod(
    //         "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=96635152&card_type=group&source=qrcode");
    //   });
    // }
  }

  void onChange1(val, [String a]) {
    setState(() {});
  }

  // Future<Uint8List> _capturePng(GlobalKey globalKey) async {
  //   RenderRepaintBoundary boundary =
  //       globalKey.currentContext.findRenderObject();
  //   ui.Image image =
  //       await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
  //   ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List picBytes = byteData.buffer.asUint8List();
  //   return picBytes;
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MToolKitNotifier mToolKitNotifier = Provider.of<MToolKitNotifier>(context);
    return MaterialApp(
      title: "软件关于",
      theme: ThemeData(
        fontFamily: Platform.isLinux ? "NotoSansCJK-Regular" : null,
        brightness: mToolKitNotifier.primaryColorBrightness,
        primaryColorBrightness: mToolKitNotifier.primaryColorBrightness,
        // accentColor: Color(0xff811016),
        primaryColor: mToolKitNotifier.backgroundColor,
        splashColor: Color(0x22811016),
      ),
      home: Scaffold(
          backgroundColor: mToolKitNotifier.backgroundColor,
          body: Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: FractionalOffset.center,
                  child: PreferredSize(
                    child: Container(
                      child: AppBar(
                        leading: Center(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)),
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
                        title: Text(
                          "关于",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        titleSpacing: 0.0,
                        elevation: 0.0,
                        actions: <Widget>[],
                        // backgroundColor: Color(0xfff9f9f9),
                      ),
                      decoration: BoxDecoration(
                          // color: Colors.red
                          // color: Color(0xfff9f9f9),
                          // gradient: LinearGradient(
                          //   begin: Alignment.topLeft,
                          //   end: Alignment.bottomRight,
                          //   colors: [
                          //     Colors.deepPurpleAccent,
                          //     // Colors.deepPurple,
                          //     // Colors.deepOrange,
                          //     Colors.deepOrangeAccent,
                          //   ],
                          // ),
                          ),
                    ),
                    preferredSize: Size(MediaQuery.of(context).size.width, 60),
                  ),
                ),
                Transform(
                  transform: Matrix4.identity()..translate(0.0, 90.0),
                  alignment: FractionalOffset.center,
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 30)),
                      ExplosionWidget(
                        ink: false,
                        tag: "logo",
                        child: Container(
                          width: 180,
                          height: 180,
                          child: RotatedView(
                            onLongPress: () {
                              PlatformChannel.JuanZheng.invokeMethod(
                                  "http://weibo.com/SorrowDespair");
                            },
                            // speedCallBack: (double value){
                            //   onChange(value);
                            // },
                            callback: (value) => onChange1(value),
                            tag: "logo0",
                            child: Stack(
                              children: <Widget>[
                                // CustomPaint(
                                //     size: Size(
                                //       screen(350),
                                //       screen(350),
                                //     ),
                                //     painter: LauntureLogo()),
                                Center(
                                  child: CustomPaint(
                                    size: Size(
                                      350,
                                      350,
                                    ),
                                    painter: Logo(
                                        color: mToolKitNotifier.fontsColor),
                                  ),
                                ),
                              ],
                            ),
                            useSensor: false,
                            reverse: true,
                            haveInertia: true,
                          ),
                        ),
                      ),
                      // RepaintBoundary(
                      //   key: rootWidgetKey,
                      //   child: SizedBox(
                      //     height: 72 / ui.window.devicePixelRatio,
                      //     width: 72 / ui.window.devicePixelRatio,
                      //     child: Stack(
                      //       alignment: Alignment.center,
                      //       children: <Widget>[
                      //         // Container(
                      //         //   color: Colors.black,
                      //         // ),
                      //         Center(
                      //           child: CustomPaint(
                      //             size: Size(
                      //               72 / ui.window.devicePixelRatio,
                      //               72 / ui.window.devicePixelRatio,
                      //             ),
                      //             painter: LauntureLogo(color: appColor),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      Shimmer.fromColors(
                        baseColor: Colors.black,
                        highlightColor: Colors.white,
                        child: SizedBox(
                          child: Row(
                            children: <Widget>[
                              Text(
                                "开发者:梦魇兽",
                                style: TextStyle(
                                    fontSize:
                                        2.75 * 16 / window.devicePixelRatio,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "前言：MToolkit这一工具算作者学习Flutter的一个学习成果，其实里面大部分功能其他软件也有，具体原理都差不多，作者会一直维护这个软件的更新，其中有部分功能是专门为作者的定制系统打造的，一些额外的功能要额外的反编译资源的支持",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "关于作者：现在是大二本科在读，时间真的是非常少，学校的教学进度很慢，开发所使用的技术都是作者自己一点一点自学的，避免不了会有遗漏的地方，最近正在完整的重构这个软件，一边上课一边维护软件的确挺不容易，感谢大家的支持。",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "关于付费：工具箱在经过一定时间的测试后增加了ROM定制功能的付费，付费价格也是根据各个ROMER定制ROM的收费情况来定的，希望这个功能能让大家自己学会定制ROM",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "如果你认为我做的这些对你有一些帮助，欢迎给作者捐助，捐助数额随意，重在心意。",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}

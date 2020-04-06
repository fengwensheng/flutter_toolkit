import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_toolkit/provider/change_notifier.dart';
import 'package:flutter_toolkit/utils/global_function.dart';
import 'package:flutter_toolkit/utils/info.dart';
import 'package:provider/provider.dart';

class DrawerItem extends StatefulWidget {
  final IconData iconData;
  final String text;
  final Function setState;
  const DrawerItem({Key key, this.iconData, this.text, this.setState})
      : super(key: key);
  @override
  _DrawerItemState createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem>
    with SingleTickerProviderStateMixin {
  Matrix4 matrix4;
  AnimationController _animationController; //动画控制器
  HomePageNotifier _homePageNotifier;
  Animation curvedAnimation;

  Animation<double> tweenPadding; //边距动画补间值
  bool isVibrate = false; //确保只震动提醒一次

  List<Color> colors = [
    Color(0xffef92a5),
    Color(0xff73b3fa),
    Color(0xffb4d761),
    Color(0xffcc99fe),
    Color(0xff6d998e),
    Colors.deepPurple,
    Colors.indigo,
  ];
  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.bounceOut);
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
  }

  void _handleDragStart(DragStartDetails details) {
    //控件点击的回调
    _tmp = details.globalPosition.dx;
  }

  double _tmp;
  void _handleDragUpdate(DragUpdateDetails details) {
    // print(details.globalPosition);
    dx = (details.globalPosition.dx - _tmp);

    if (dx < 0) dx = 0;
    if (!isVibrate && dx.abs() >100.0) {
      isVibrate = true;
      // Vibration.vibrate(duration: 50, amplitude: 255);
    }
    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (isVibrate) {
      isVibrate = false;
      Info.setValue("首页", widget.text);
      widget.setState();
      showToast2("${widget.text}已被设置为主页面");
    }
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
    tweenPadding.addListener(() {
      setState(() {
        dx = tweenPadding.value;
      });
    });
    _animationController.reset();
    _animationController.forward().whenComplete(() {});
  }

  double dx = 0.0;
  @override
  Widget build(BuildContext context) {
    _homePageNotifier = Provider.of<HomePageNotifier>(context);
    // customLog(widget, _homePageNotifier.defaultPage);
    return SizedBox(
      height: 46.0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.grey,
              child: SizedBox(
                height: 45.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "  震动后松开设置为主页面",
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
              ),
            ),
          ),
          Transform(
            transform: Matrix4.identity()..translate(dx),
            child: Material(
              color: Theme.of(context).backgroundColor,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();

                  _homePageNotifier.changePage(widget.text);
                },
                child: SizedBox(
                  height: 46.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: _handleDragStart,
                    onHorizontalDragUpdate: _handleDragUpdate,
                    onHorizontalDragEnd: _handleDragEnd,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 20.0,
                          padding: EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                          child: Icon(
                            widget.iconData,
                            size: 20.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                          child: Text(
                            widget.text,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_homePageNotifier.currentRoute == widget.text)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 6.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: colors[Random().nextInt(6)],
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(8),
                      topRight: Radius.circular(8)),
                ),
              ),
            ),
          if (Info.getValue("首页") == widget.text)
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.home,
                size: 16.0,
              ),
            ),
        ],
      ),
    );
  }
}

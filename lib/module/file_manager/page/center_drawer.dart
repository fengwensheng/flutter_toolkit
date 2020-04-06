import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class CenterDrawer extends StatefulWidget {
  @override
  _CenterDrawerState createState() => _CenterDrawerState();
}

class _CenterDrawerState extends State<CenterDrawer>
    with SingleTickerProviderStateMixin {
  AnimationController _topDrawerController; //上面那个小箭头点击后的动画控制器
  @override
  void initState() {
    super.initState();
    _topDrawerController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _topDrawerController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _topDrawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQueryData.fromWindow(window).padding.top +
                  kToolbarHeight,
            ),
            child: Stack(
              children: <Widget>[
                _topDrawerController.value != 0.0
                    ? Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Container(
                          color: Colors.black
                              .withOpacity(0.4 * _topDrawerController.value),
                        ),
                      )
                    : SizedBox(),
                _topDrawerController.value != 0.0
                    ? ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          height: 120.0 * _topDrawerController.value + 24.0,
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ),
        Align(
          //中上点击可以旋转的箭头
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQueryData.fromWindow(window).padding.top +
                  kToolbarHeight -
                  14.00,
            ),
            child: Transform(
              transform: Matrix4.identity()
                ..rotateZ(pi * _topDrawerController.value),
              alignment: FractionalOffset.center,
              child: SizedBox(
                height: 36.0,
                width: 36.0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      if (!_topDrawerController.isAnimating) {
                        if (_topDrawerController.isDismissed) {
                          _topDrawerController.forward();
                        } else {
                          _topDrawerController.reverse();
                        }
                      }
                    },
                    child: Icon(Icons.arrow_drop_down, size: 24.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

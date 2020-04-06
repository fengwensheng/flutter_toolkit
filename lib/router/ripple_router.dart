import 'dart:math';

import 'package:flutter/material.dart';

class RouteConfig {
  Offset offset;
  double circleRadius;
  RouteConfig.fromSize(Size size) {
    offset = size.center(Offset.zero);
    if (offset.dx > size.width / 2) {
      if (offset.dy > size.height / 2) {
        circleRadius = sqrt(pow(offset.dx, 2) + pow(offset.dy, 2)).toDouble();
      } else {
        circleRadius = sqrt(pow(offset.dx, 2) + pow(size.height - offset.dy, 2))
            .toDouble();
      }
    }
    if (offset.dx <= size.width / 2) {
      if (offset.dy > size.height / 2) {
        circleRadius =
            sqrt(pow(size.width - offset.dx, 2) + pow(offset.dy, 2)).toDouble();
      } else {
        circleRadius = sqrt(pow(size.width - offset.dx, 2) +
                pow(size.height - offset.dy, 2))
            .toDouble();
      }
    }
  }
  RouteConfig.of(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    offset = size.center(Offset.zero);
    if (offset.dx > size.width / 2) {
      if (offset.dy > size.height / 2) {
        circleRadius = sqrt(pow(offset.dx, 2) + pow(offset.dy, 2)).toDouble();
      } else {
        circleRadius = sqrt(pow(offset.dx, 2) + pow(size.height - offset.dy, 2))
            .toDouble();
      }
    }
    if (offset.dx <= size.width / 2) {
      if (offset.dy > size.height / 2) {
        circleRadius =
            sqrt(pow(size.width - offset.dx, 2) + pow(offset.dy, 2)).toDouble();
      } else {
        circleRadius = sqrt(pow(size.width - offset.dx, 2) +
                pow(size.height - offset.dy, 2))
            .toDouble();
      }
    }
  }

  RouteConfig.fromContext(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject();
    offset = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    if (offset.dx > MediaQuery.of(context).size.width / 2) {
      if (offset.dy > MediaQuery.of(context).size.height / 2) {
        circleRadius = sqrt(pow(offset.dx, 2) + pow(offset.dy, 2)).toDouble();
      } else {
        circleRadius = sqrt(pow(offset.dx, 2) +
                pow(MediaQuery.of(context).size.height - offset.dy, 2))
            .toDouble();
      }
    }
    if (offset.dx <= MediaQuery.of(context).size.width / 2) {
      if (offset.dy > MediaQuery.of(context).size.height / 2) {
        circleRadius = sqrt(
                pow(MediaQuery.of(context).size.width - offset.dx, 2) +
                    pow(offset.dy, 2))
            .toDouble();
      } else {
        circleRadius = sqrt(
                pow(MediaQuery.of(context).size.width - offset.dx, 2) +
                    pow(MediaQuery.of(context).size.height - offset.dy, 2))
            .toDouble();
      }
    }
  }
}

// double circleRadius
class RippleRoute extends PageRouteBuilder {
  final Widget widget;
  final RouteConfig routeConfig;

  RippleRoute(this.widget, this.routeConfig)
      : super(
          // 设置过度时间
          transitionDuration: Duration(milliseconds: 400),
          // 构造器
          pageBuilder: (
            // 上下文和动画
            BuildContext context,
            Animation<double> animation,
            Animation<double> _,
          ) {
            return widget;
          },
          opaque: true,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> _,
            Widget child,
          ) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: routeConfig.offset.dy -
                      routeConfig.circleRadius * animation.value,
                  left: routeConfig.offset.dx -
                      routeConfig.circleRadius * animation.value,
                  child: SizedBox(
                    height: routeConfig.circleRadius * 2 * animation.value,
                    width: routeConfig.circleRadius * 2 * animation.value,
                    child: ClipOval(
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: routeConfig.circleRadius * animation.value -
                                routeConfig.offset.dy,
                            left: routeConfig.circleRadius * animation.value -
                                routeConfig.offset.dx,
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: child,
                              ),
                            ),
                          ),
                          if (!animation.isCompleted)
                            Container(
                              color: Colors.grey
                                  .withOpacity(0.4 * (1 - animation.value)),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          // transitionsBuilder: (
          //   BuildContext context,
          //   Animation<double> animation,
          //   Animation<double> _,
          //   Widget child,
          // ) {
          //   return Align(
          //     alignment: Alignment.center,
          //     child: Stack(
          //       children: <Widget>[
          //         Positioned(
          //           top: routeConfig.offset.dy -
          //               routeConfig.circleRadius * animation.value,
          //           left: routeConfig.offset.dx -
          //               routeConfig.circleRadius * animation.value,
          //           child: SizedBox(
          //             height: routeConfig.circleRadius * 2 * animation.value,
          //             width: routeConfig.circleRadius * 2 * animation.value,
          //             child: ClipOval(
          //                 child: Stack(
          //               alignment: Alignment.topCenter,
          //               children: <Widget>[
          //                 Positioned(
          //                   top: routeConfig.circleRadius * animation.value -
          //                       routeConfig.offset.dy,
          //                   left: routeConfig.circleRadius * animation.value -
          //                       routeConfig.offset.dx,
          //                   child: Align(
          //                     alignment: Alignment.center,
          //                     child: Container(
          //                       width: MediaQuery.of(context).size.width,
          //                       height: MediaQuery.of(context).size.height,
          //                       child: child,
          //                     ),
          //                   ),
          //                 ),
          //                 if (!animation.isCompleted)
          //                   Container(
          //                     color: Colors.grey
          //                         .withOpacity(0.4 * (1 - animation.value)),
          //                   )
          //               ],
          //             )),
          //           ),
          //         ),
          //       ],
          // ),
          // );
          // },
        );
}

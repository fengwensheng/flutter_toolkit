import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_toolkit/main.dart';

void showToast({@required BuildContext context, @required String message}) {
  //创建一个OverlayEntry对象
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) {
      //外层使用Positioned进行定位，控制在Overlay中的位置
      return Positioned(
        top: MediaQuery.of(context).size.height * 0.88,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Material(
              color: Colors.white,
              shadowColor: Colors.grey.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              elevation: 12.0,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, top: 4.0, bottom: 4.0, right: 8.0),
                  child: Text(
                    message,
                    style: TextStyle(
        fontFamily: Platform.isLinux ? "NotoSansCJK-Regular" : null,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  //往Overlay中插入插入OverlayEntry
  Overlay.of(context).insert(overlayEntry);
  //两秒后，移除Toast
  Future.delayed(Duration(milliseconds: 1500)).then((value) {
    overlayEntry.remove();
  });
}

void showToast2(String message, [String emoji]) {
  Runes input = new Runes(emoji ?? '\u{1f47b}');
  var index = String.fromCharCodes(input);
  //创建一个OverlayEntry对象

  EdgeInsets padding = MediaQuery.of(globalContext).viewInsets;
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) {
      //外层使用Positioned进行定位，控制在Overlay中的位置
      return Positioned(
        // top: MediaQuery.of(context).size.height * 0.88,
        bottom: padding.bottom + 60.0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Material(
              color: Colors.white,
              shadowColor: Colors.grey.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              elevation: 12.0,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, top: 4.0, bottom: 4.0, right: 8.0),
                  child: Text(
                    message + index,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  //往Overlay中插入插入OverlayEntry
  Overlay.of(globalContext).insert(overlayEntry);
  //两秒后，移除Toast
  Future.delayed(Duration(milliseconds: 2000)).then((value) {
    overlayEntry.remove();
  });
}

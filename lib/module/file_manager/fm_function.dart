import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';


Widget getWidgetFromExtension(String fileName, String path,
    [bool isFile = true]) {
  if (isFile) {
    if (fileName.endsWith(".zip"))
      return Icon(
        Octicons.getIconData("file-zip"),
      );
    else if (fileName.endsWith(".apk"))
      return Icon(
        Icons.android,
      );
    else if (fileName.endsWith(".mp4"))
      return Icon(
        Icons.video_library,
      );
    else if (fileName.endsWith(".jpg") || fileName.endsWith(".png")) {
      // return Imagefile(
      //   path: path,
      // );
    } else
      return Icon(
        Octicons.getIconData("file"),
      );
      return Text("");
  } else {
    return Icon(
      Octicons.getIconData("file-directory"),
    );
  }
}

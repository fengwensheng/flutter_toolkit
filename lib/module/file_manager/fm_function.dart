import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_toolkit/module/file_manager/io/file_entity.dart';

import 'io/file.dart';
import 'widgets/item_imgheader.dart';

Widget getWidgetFromExtension(
    FileEntity fileNode, BuildContext context,
    [bool isFile = true]) {
  if (isFile) {
    if (fileNode.nodeName.endsWith(".zip"))
      return SvgPicture.asset(
        "assets/icon/zip.svg",
        width: 20.0,
        height: 20.0,
        color: Theme.of(context).iconTheme.color,
      );
    else if (fileNode.nodeName.endsWith(".apk"))
      return Icon(
        Icons.android,
      );
    else if (fileNode.nodeName.endsWith(".mp4"))
      return Icon(
        Icons.video_library,
      );
    else if (fileNode.nodeName.endsWith(".jpg") || fileNode.nodeName.endsWith(".png")) {
      return ItemImgHeader(
        fileNode: fileNode,
      );
    } else
      return SvgPicture.asset(
        "assets/icon/file.svg",
        width: 20.0,
        height: 20.0,
      );
  } else {
    return SvgPicture.asset(
      "assets/icon/directory.svg",
      width: 20.0,
      height: 20.0,
      color: Theme.of(context).iconTheme.color,
    );
  }
}

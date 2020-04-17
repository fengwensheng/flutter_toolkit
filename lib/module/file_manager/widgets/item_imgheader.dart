import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_toolkit/common/envirpath.dart';
import 'package:flutter_toolkit/module/file_manager/io/file.dart';

class ItemImgHeader extends StatefulWidget {
  final NiFile fileNode;

  const ItemImgHeader({Key key, this.fileNode}) : super(key: key);
  @override
  _ItemImgHeaderState createState() => _ItemImgHeaderState();
}

class _ItemImgHeaderState extends State<ItemImgHeader> {
  GlobalKey rootWidgetKey = GlobalKey();
  bool prepare = false;
  String imgPath;
  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    if (!await Directory("${EnvirPath.filesPath}/FileManager/img_cache")
        .exists()) {
      Directory("${EnvirPath.filesPath}/FileManager/img_cache")
          .createSync(recursive: true);
    }
    String cacheName = widget.fileNode.path.replaceAll("/", "_");
    bool cacheExist =
        await File("${EnvirPath.filesPath}/FileManager/img_cache/$cacheName")
            .exists();
    if (cacheExist) {
      imgPath = "${EnvirPath.filesPath}/FileManager/img_cache/$cacheName";
      prepare = true;
      setState(() {});
      saveCacheImg();
    } else {
      imgPath = widget.fileNode.path;
      prepare = true;
      setState(() {});
      saveCacheImg();
    }
  }

  saveCacheImg() {
    String cacheName = widget.fileNode.path.replaceAll("/", "_");
    Future.delayed(Duration(milliseconds: 300), () async {
      Uint8List _aa = await _capturePng(rootWidgetKey);
      if (_aa == null) {
        imgPath = widget.fileNode.path;
        prepare = true;
        setState(() {});
        saveCacheImg();
        return;
      }
      File("${EnvirPath.filesPath}/FileManager/img_cache/$cacheName")
          .writeAsBytesSync(_aa);
    });
  }

  Future<Uint8List> _capturePng(GlobalKey globalKey) async {
    if (globalKey.currentContext != null) return null;
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image =
        await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List picBytes = byteData.buffer.asUint8List();
    return picBytes;
  }

  @override
  Widget build(BuildContext context) {
    return prepare
        ? RepaintBoundary(
            key: rootWidgetKey,
            child: Hero(
              tag: widget.fileNode.path,
              child: Image.file(File(imgPath)),
            ))
        : SizedBox();
  }
}

// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';



// class Imagefile extends StatefulWidget {
//   final String path;

//   const Imagefile({Key key, this.path}) : super(key: key);
//   @override
//   _ImagefileState createState() => _ImagefileState();
// }

// class _ImagefileState extends State<Imagefile> {
//   Widget _image;
//   Uint8List _uint2list;
//   GlobalKey rootWidgetKey = GlobalKey();
//   @override
//   void initState() {
//     getimage(() {});
//     super.initState();
//   }

//   Future<Uint8List> _capturePng(GlobalKey globalKey) async {
//     RenderRepaintBoundary boundary =
//         globalKey.currentContext.findRenderObject();
//     ui.Image image =
//         await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
//     ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     Uint8List picBytes = byteData.buffer.asUint8List();
//     return picBytes;
//   }

//   Future getimage(Function fun) async {
//     for (FileSystemEntity _file in appDocDir.listSync()) {
//       if (_file.path.replaceAll(RegExp(".*/"), "") ==
//           widget.path.replaceAll("/", "_")) {
//         _uint2list = File(_file.path).readAsBytesSync();
//       }
//     }
//     if (_uint2list == null||_uint2list.length<=200) {
//       _uint2list = File(widget.path).readAsBytesSync();
//       _image = Image.memory(_uint2list);
//       setState(() {});
//       await saveimg();
//       // getimage(() {
//       //   setState(() {});
//       // });
//     }
//     ImageCache().clear();
//     // getMemoryImageCache();
//     fun();
//   }

//   Future saveimg() async {
//     if (!File(appDocDir.path + "/" + widget.path.replaceAll("/", "_"))
//         .existsSync()) {
//       Future.delayed(Duration(milliseconds: 200), () async {
//         Uint8List _aa = await _capturePng(rootWidgetKey);
//         File(appDocDir.path + "/" + widget.path.replaceAll("/", "_"))
//             .writeAsBytesSync(_aa);
//       });
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_image == null)
//       _image = Image.file(
//           File(appDocDir.path + "/" + widget.path.replaceAll("/", "_")));
//     return RepaintBoundary(key: rootWidgetKey, child: _image);
//   }
// }

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toolkit/common/envirpath.dart';
import 'package:flutter_toolkit/utils/native.dart';

class VideoPlay extends StatefulWidget {
  final String filePath;

  const VideoPlay({Key key, this.filePath}) : super(key: key);
  @override
  _VideoPlayState createState() => _VideoPlayState();
}

List<int> tmp = [];

Future<void> runTimer(SendPort sendPort) async {
  String libPath = FileSystemEntity.parentOf(Platform.resolvedExecutable) +
      "/lib/libnative-lib.so";
  print(libPath);
  var receivePort = new ReceivePort();
  sendPort.send(receivePort.sendPort);
  String path = await receivePort.first;
  var dylib = DynamicLibrary.open(libPath);
  var bofang = dylib.lookup<NativeFunction<videoStreamPlay>>("videoStreamPlay");
  VideoStreamPlay videoStrmPlay = bofang.asFunction<VideoStreamPlay>();
  EnvirPath.filesPath =
      "${FileSystemEntity.parentOf(Platform.resolvedExecutable)}/data";
  videoStrmPlay(Utf8.toUtf8(path));
  // ServerSocket.bind('127.0.0.1', 8887) //绑定端口4041，根据需要自行修改，建议用动态，防止端口占用
  //     .then((serverSocket) {
  //   // port.send("启动的回调");

  //   serverSocket.listen((socket) {
  //     var tmpData = "";
  //     print(socket);
  //     socket.listen((s) {
  //       port.send(s);
  //     });
  //   });
  // });
  receivePort.listen((message) {
    print("来自主islate的消息===>$message");
  });
}

class _VideoPlayState extends State<VideoPlay> {
  Uint8List uint8list;
  Isolate isolate;
  int index = 0;
  bool isStart = false;
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 10), () async {
      while (true) {
        ImageCache().clear();
        // print("判断$index");
        if (await File("${EnvirPath.filesPath}/Frame/${index + 1}").exists()) {
          File("${EnvirPath.filesPath}/Frame/$index\.jpg").delete();
          File("${EnvirPath.filesPath}/Frame/$index").delete();
          index++;
        }
        if (await File("${EnvirPath.filesPath}/Frame/$index").exists()) {
          isStart = true;
          // uint8list=await File("/sdcard/MToolkit/Frame/$index").readAsBytes();
          await precacheImage(
              FileImage(File("${EnvirPath.filesPath}/Frame/$index.jpg")),
              context);
          // }
          setState(() {});
        }
        await Future.delayed(Duration(milliseconds: 20));
      }
    });
    String libPath = FileSystemEntity.parentOf(Platform.resolvedExecutable) +
        "/lib/libnative-lib.so";
    var dylib = DynamicLibrary.open(libPath);
    var pointer =
        dylib.lookup<NativeFunction<init_dart_print>>("init_dart_print");
    InitDartPrint initDartPrint = pointer.asFunction<InitDartPrint>();
    Pointer<NativeFunction<Void Function(Pointer<Utf8>)>> a =
        Pointer.fromFunction(dartPrintFunc);
    initDartPrint(a);
    init();
  }

  init() async {
    index = 0;
    setState(() {});
    final receive = ReceivePort();
    isolate = await Isolate.spawn(runTimer, receive.sendPort);
    var sendPort = await receive.first;
    print("isolate启动");
    sendPort.send(widget.filePath);
    receive.listen((data) {
      print("来自子isolate的消息====>$data");
      setState(() {});
    });
  }
  @override
  void dispose() {
    isolate.kill(
      priority: Isolate.immediate
    );
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isStart
          ? Image.file(File("${EnvirPath.filesPath}/Frame/$index.jpg"))
          : SizedBox(
              child: Text('data'),
            ),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   index = 0;
      //   setState(() {});
      //   final receive = ReceivePort();
      //   isolate = await Isolate.spawn(runTimer, receive.sendPort);
      //   // print(DateTime.now().toString() + " Socket服务启动，正在监听端口 4041...");
      //   print("isolate启动");
      //   receive.listen((data) {
      //     setState(() {});
      //   });
      // }),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_toolkit/main.dart';
import 'package:flutter_toolkit/module/file_manager/provider/file_manager_notifier.dart';
import 'package:flutter_toolkit/module/term/term.dart';
import 'package:flutter_toolkit/utils/global_function.dart';
import 'package:flutter_toolkit/utils/process.dart';
import 'package:provider/provider.dart';

class Copy extends StatefulWidget {
  final String targetPath;
  final List<String> sourcePaths;
  const Copy({Key key, this.targetPath, this.sourcePaths}) : super(key: key);
  @override
  _CopyState createState() => _CopyState();
}

class _CopyState extends State<Copy> {
  String curCpFile = ""; //当前复制的文件为
  String text = "";
  int fullByte = 0;
  int alreadyCpByte = 0;
  int sum;
  double curProgress = 0.0;
  int cpFilePreByte = 0;
  bool isComplete = false;
  List<String> queue = [];
  List<String> sourcePaths = [];
  String tmp1 = "";
  String tmp2 = "";
  String speed = "";
  @override
  void initState() {
    super.initState();
    initCopy();
    // getCurrentProgess();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
  }

  @override
  void didUpdateWidget(Copy oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
  }

  void _onAfterRendering(Duration timeStamp) {
    // if (mounted) setState(() {});
  }

  getCurrentProgess() async {
    while (sourcePaths.isEmpty) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    while (sourcePaths.isNotEmpty && mounted) {
      curCpFile = sourcePaths.first;
      String targetPath =
          "${widget.targetPath}${sourcePaths.first.replaceAll(FileSystemEntity.parentOf(widget.sourcePaths[0]), "")}";
      print("判断==>$targetPath");
      while (true) {
        if (await Directory(targetPath).exists() ||
            await File(targetPath).exists()) break;
        await Future.delayed(Duration(microseconds: 0));
      }
      if (await Directory(targetPath).exists()) {
        curProgress = 1.0;
        speed = "";
        cpFilePreByte = 0;
        alreadyCpByte += 4096;
        if (mounted) setState(() {});
      } else if (await File(targetPath).exists() &&
          await File(sourcePaths[0]).length() ==
              await File(targetPath).length()) {
        curProgress = 1.0;
        speed = "";
        cpFilePreByte = 0;
        alreadyCpByte += await File(targetPath).length();
        if (mounted) setState(() {});
      } else if (await File(targetPath).exists()) {
        curProgress = await File(targetPath).length() /
            await File(sourcePaths[0]).length();
        setState(() {});
        DateTime dateTime = DateTime.now();
        while (true) {
          if (DateTime.now().difference(dateTime).inMilliseconds >= 200) {
            dateTime = DateTime.now();
            int size = await File(targetPath).length() - cpFilePreByte;
            alreadyCpByte += size;
            speed = "${getFileSize(size * 5)}/s";
            cpFilePreByte = await File(targetPath).length();
          }
          curProgress = await File(targetPath).length() /
              await File(sourcePaths[0]).length();
          if (mounted) setState(() {});
          if (curProgress == 1.0) break;
          await Future.delayed(Duration(milliseconds: 1));
        }
        // completeNumber++;
      }
      while (true) {
        if (curCpFile != sourcePaths.first) break;
        await Future.delayed(Duration(microseconds: 0));
      }
    }

    if (sourcePaths.isEmpty) {
      showToast2("完成");
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.of(globalContext).pop();
    }
  }

  initCopy() async {
    // DateTime a = DateTime.now();
    String allPaths = "";
    for (String path in widget.sourcePaths) {
      allPaths += await CustomProcess.exec("find $path -not -type l \n");
      allPaths += "\n";
      String daxiao = await CustomProcess.exec(
          "find $path -not -type l |xargs busybox stat -c \"%s\"|awk '{sum1+= \$1}END{print sum1}'\n");
      // print(daxiao);
      fullByte += int.tryParse(daxiao.trim());
      // print(int.tryParse(daxiao.replaceAll(RegExp("t.*"), "").trim()) * 1024);
    }
    fullByte = fullByte;
    setState(() {});
    // print("耗时=====>${DateTime.now().difference(a)}");
    sourcePaths = allPaths.trim().split("\n");

    // print("耗时=====>${DateTime.now().difference(a)}");
    // for (int i = 0; i < sourcePaths.length; i++) {
    //   sourcePaths[i] = sourcePaths[i]
    //       .replaceFirst(FileSystemEntity.parentOf(sourcePaths[i]), "");
    // }
    // print("allPaths=====>$sourcePaths");
    // print("allPaths=====>${sourcePaths.length}");
    // print(widget.targetPath);
    sum = sourcePaths.length;
    setState(() {});
    // print("cp -Lrv ${widget.sourcePath} ${widget.targetPath}\n");
    bool isStart = false;
    String tmp = "";
    RegExp lineRegExp = RegExp("'.*' -> '.*'");
    Niterm.getOutPut((output) async {
      if (!mounted) return true;
      output = tmp + output;
      tmp = "";
      // tmp2+=output;
      // File("/sdcard/MToolkit/日志文件夹/文件复制.txt").writeAsString(tmp2);
      // output=tmp+output;
      // print("来自term的输出===>$output");
      if (output.contains("\n")) {
        for (String pathLine in output.split("\n")) {
          if (pathLine.startsWith("'")) isStart = true;
          if (isStart) {
            if (lineRegExp.hasMatch(pathLine)) {
              // curProgress = 0.0;
              if (sourcePaths.isNotEmpty) sourcePaths.removeAt(0);
              setState(() {});
              if (sourcePaths.isEmpty) {
                fiMaPageNotifier.clearClipBoard();
                Future.delayed(Duration(milliseconds: 200), () {
                  Navigator.of(context).pop();
                });
                break;
              }
              String targetPath =
                  "${widget.targetPath}${sourcePaths.first.replaceAll(FileSystemEntity.parentOf(widget.sourcePaths[0]), "")}";
              print("判断==>$targetPath");
              while (true) {
                if (await Directory(targetPath).exists() ||
                    await File(targetPath).exists()) break;
                await Future.delayed(Duration(microseconds: 0));
              }
              if (await Directory(targetPath).exists()) {
                curProgress = 1.0;
                speed = "";
                cpFilePreByte = 0;
                alreadyCpByte += 4096;
                if (mounted) setState(() {});
              } else if (await File(targetPath).exists() &&
                  await File(sourcePaths[0]).length() ==
                      await File(targetPath).length()) {
                curProgress = 1.0;
                speed = "";
                cpFilePreByte = 0;
                alreadyCpByte += await File(targetPath).length();
                if (mounted) setState(() {});
              } else if (await File(targetPath).exists()) {
                curProgress = await File(targetPath).length() /
                    await File(sourcePaths[0]).length();
                setState(() {});
                DateTime dateTime = DateTime.now();
                while (true) {
                  if (DateTime.now().difference(dateTime).inMilliseconds >=
                      200) {
                    dateTime = DateTime.now();
                    int size = await File(targetPath).length() - cpFilePreByte;
                    alreadyCpByte += size;
                    speed = "${getFileSize(size * 5)}/s";
                    cpFilePreByte = await File(targetPath).length();
                  }
                  curProgress = await File(targetPath).length() /
                      await File(sourcePaths[0]).length();
                  if (curProgress == 1.0) {
                    int size = await File(targetPath).length() - cpFilePreByte;
                    alreadyCpByte += size;
                    break;
                  }
                  if (mounted) setState(() {});
                  await Future.delayed(Duration(milliseconds: 1));
                }
                // completeNumber++;
              }
            } else
              tmp = pathLine;
          }
          // List pathLineList =
          //     pathLine.trim().replaceAll(RegExp("^cp '"), "").split(" -> ");
          // String sourcePath = pathLineList[0].replaceAll(RegExp("^'|'\$"), "");
          // String targetPath = pathLineList[1].replaceAll(RegExp("^'|'\$"), "");

        }
      } else
        tmp = output;
      return false;
    });
    String script = "";
    for (String path in widget.sourcePaths) {
      script += "cp -Lrv $path ${widget.targetPath}\n";
    }
    Niterm.exec("sh -c \"$script\"\n");
  }

  @override
  void dispose() {
    Niterm.exec(String.fromCharCode(3));
    super.dispose();
  }

  FiMaPageNotifier fiMaPageNotifier;
  @override
  Widget build(BuildContext context) {
    fiMaPageNotifier = Provider.of<FiMaPageNotifier>(context, listen: false);

    return SizedBox(
      height: 140.0,
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Row(
            children: <Widget>[
              Text("剩余项："),
              if (sum == null)
                SpinKitThreeBounce(
                  color: Theme.of(context).accentColor,
                  size: 16.0,
                )
              else
                Text("${sourcePaths.length}"),
            ],
          ),
          SizedBox(
            height: 64.0,
            child: sourcePaths.isNotEmpty
                ? Text(
                    "复制文件${sourcePaths.first}",
                    maxLines: 4,
                  )
                : Text("复制结束"),
          ),
          Text("当前进度:$speed"),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: SizedBox(
              height: 4.0,
              child: LinearProgressIndicator(
                value: curProgress,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
                backgroundColor: Colors.grey,
              ),
            ),
          ),
          Text("总进度:(${getFileSize(alreadyCpByte)}/${getFileSize(fullByte)})"),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: SizedBox(
              height: 4.0,
              child: LinearProgressIndicator(
                value: sum == null
                    ? 0.0
                    : (sum - sourcePaths.length) / sum.toDouble(),
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
                backgroundColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

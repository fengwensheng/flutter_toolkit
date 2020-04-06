import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:flutter_toolkit/common/envirpath.dart';
import 'package:flutter_toolkit/utils/apktool_func.dart';
import 'package:flutter_toolkit/utils/global_function.dart';

import 'common/constant.dart';
import 'model/term.dart';
import 'term_func.dart';
import 'utils/custom_utf.dart';

class Niterm extends StatefulWidget {
  static List<Term> terms = []; //终端模拟器的列表
  static String libPath = 'libterm.so'; //so库的路径
  final String script; //外部唤起改widget自动执行的脚本
  static DynamicLibrary dylib; //dylib对象
  final bool showOnDialog; //是否是dialog唤起的

  const Niterm({Key key, this.script, this.showOnDialog = false})
      : super(key: key);

  static void creatNewTerm() async {
    if (Platform.isMacOS) {
      libPath =
          "/Users/nightmare/Library/Containers/com.nightmareTool/Data/libterm.dylib";
    }
    if (Platform.isLinux) {
      libPath = FileSystemEntity.parentOf(Platform.resolvedExecutable) +
          "/lib/libterm.so";
    }
    dylib = DynamicLibrary.open(libPath);
    //等价于  char **argv;
    //指向创建ptm的指针
    final getPtmIntPointer =
        dylib.lookup<NativeFunction<create_ptm>>('create_ptm');
    //初始化dart中对应的创建ptm的函数
    final CreatePtm createPtm = getPtmIntPointer.asFunction<CreatePtm>();
    //调用创建
    int currentPtm = createPtm(200, 200);
    // free(ptsPath);
    Term term;
    term = Term(currentPtm);
    final createSubprocessPointer =
        dylib.lookup<NativeFunction<create_subprocess>>('create_subprocess');
    CreateSubprocess createSubprocess =
        createSubprocessPointer.asFunction<CreateSubprocess>();
    Pointer<Pointer<Utf8>> argv = allocate(count: 1);
    argv[0] = Pointer.fromAddress(0);
    Pointer<Pointer<Utf8>> envp;
    Map<String, String> environment = {};
    environment.addAll(Platform.environment);
    environment["PATH"] =
        "${EnvirPath.filesPath}/usr/bin:" + environment["PATH"];
    envp = allocate(count: environment.keys.length + 1);
    for (int i = 0; i < environment.keys.length; i++) {
      envp[i] = Utf8.toUtf8(
          "${environment.keys.elementAt(i)}=${environment[environment.keys.elementAt(i)]}");
    }
    envp[environment.keys.length] = Pointer.fromAddress(0);
    Pointer<Int32> p = allocate();
    p.value = 0;
    String shPath;
    if (Platform.isAndroid)
      shPath = '/system/bin/sh';
    else
      shPath = "sh";
    createSubprocess(
        Utf8.toUtf8(''),
        Utf8.toUtf8(shPath),
        Utf8.toUtf8(
            Platform.isAndroid ? '/data/data/com.nightmare/files/home' : "."),
        argv,
        envp,
        p,
        currentPtm);
    term.pid = p.value;
    terms.add(term);
    print(p.value);
    free(p);
  }

  static exec(String script) {
    if (!script.endsWith("\n")) script += "\n";
    final writetofdpointer =
        dylib.lookup<NativeFunction<write_to_fd>>('write_to_fd');
    WriteToFd writeToFd = writetofdpointer.asFunction();
    writeToFd(Niterm.terms.first.ptm, Utf8.toUtf8("$script"));
    // for (String line in script.trim().split("\n")) {
    //   writeToFd(Niterm.terms.first.ptm, Utf8.toUtf8("$line\n"));
    // }
  }

  static getOutPut(Future<bool> Function(String line) callBack) {
    final getOutFromFdPointer =
        dylib.lookup<NativeFunction<get_output_from_fd>>('get_output_from_fd');
    GetOutFromFd getOutFromFd = getOutFromFdPointer.asFunction();
    Future.delayed(
      Duration(seconds: 1),
      () async {
        while (Niterm.terms.isNotEmpty) {
          // Utf8.fromUtf8(string)
          Pointer<Uint8> resultPoint = getOutFromFd(Niterm.terms.first.ptm);
          if (resultPoint.address != 0) {
            String result = "";
            try {
              result = CustomUtf.cStringtoString(resultPoint);
            } catch (e) {
              print("转换出错=====>$e");
            }
            if (await callBack(result)) {
              print("停止");
              free(resultPoint);
              break;
            }
          }
          free(resultPoint);
          await Future.delayed(Duration(microseconds: 0));
        }
        print("停止了");
      },
    );
  }

  @override
  _NitermState createState() => _NitermState();
}

// EventBus eventbus=EventBus();
class _NitermState extends State<Niterm> {
  int cursor = 0; //光标的位置
  bool isUseCtrl = false; //一个检测是否按下CTRL键的布尔值
  List<InlineSpan> listSpan = []; //符文本列表
  String termOutput = ""; //终端的输出
  WriteToFd writeToFd; //向文件描述符写入输出的方法
  GetOutFromFd getOutFromFd; //从文件描述符获取输出的方法
  bool popbool; //禁止返回的布尔值
  TextEditingController editingController = TextEditingController(); //输入框文本控制器
  FocusNode focusNode = FocusNode(); //输入框焦点
  String textTmp = ""; //这是Textfield的缓存文本,用来判断用户是删除还是输入字符
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    init();
  }

  List apktoolFuncs = ["apktool", "baksmali", "smali"];
  init() async {
    //设置so库等的路径
    popbool = widget.showOnDialog ? false : true;
    // forcePop=widget.showOnDialog?false;
    final getOutFromFdPointer = Niterm.dylib
        .lookup<NativeFunction<get_output_from_fd>>('get_output_from_fd');
    getOutFromFd = getOutFromFdPointer.asFunction();
    final writetofdpointer =
        Niterm.dylib.lookup<NativeFunction<write_to_fd>>('write_to_fd');
    writeToFd = writetofdpointer.asFunction();
    //如果传进来了自动执行的命令
    if (widget.script != null) {
      Future.delayed(
        Duration(milliseconds: 0),
        () async {
          for (String line in widget.script.trim().split("\n")) {
            // print("line===>$line");
            if (!mounted) break;
            writeToFd(Niterm.terms.first.ptm, Utf8.toUtf8(line + "\n"));
            if (listCommond.contains(line) ||
                line.startsWith(apktoolFuncs[0]) ||
                line.startsWith(apktoolFuncs[1]) ||
                line.startsWith(apktoolFuncs[2])) {
              while (true) {
                print("向终端输入======>$line");
                await Future.delayed(Duration(milliseconds: 100));
                if (!termOutput.endsWith("\$ ") || !termOutput.endsWith("\# "))
                  break;
                if (!termOutput.endsWith("\$") || !termOutput.endsWith("\#"))
                  break;
              }
              while (true) {
                // print(termOutput.substring(termOutput.length-3,termOutput.length-1));
                await Future.delayed(Duration(milliseconds: 100));
                if (termOutput.endsWith("\$ ") || termOutput.endsWith("\# "))
                  break;
                if (Platform.isLinux) if (termOutput
                        .substring(termOutput.length - 7, termOutput.length - 1)
                        .contains("\$") ||
                    termOutput
                        .substring(termOutput.length - 7, termOutput.length - 1)
                        .contains("\#")) break;
              }
            }
            if (line == "su")
              await Future.delayed(Duration(milliseconds: 1000));
          }
          if (widget.showOnDialog) {
            writeToFd(Niterm.terms.first.ptm,
                Utf8.toUtf8("echo Nightmare_exit_true" + "\n"));
          }
        },
      );
    }

    Future.delayed(Duration(milliseconds: 100), () async {
      while (mounted && Niterm.terms.isNotEmpty) {
        // Utf8.fromUtf8(string)
        Pointer<Uint8> resultPoint = getOutFromFd(Niterm.terms.first.ptm);
        if (resultPoint.address != 0) {
          for (int i = 0; i < cursor; i++) {
            termOutput = termOutput.substring(0, termOutput.length - 1);
          }
          cursor = 0;
          String result = "";
          try {
            result = CustomUtf.cStringtoString(resultPoint);
          } catch (e) {
            //以防万一不能转换
            print("转换出错=====>$e");
          }
          // print("codeUnits===》${Utf8Codec().encode(result)}");
          // print(result);
          var resetStr = Utf8Codec().decode(TERM_RESET);
          if (result.contains(resetStr)) {
            // print(result);
            // //这是reset命令按下的终端输出units序列

            termOutput = termOutput.replaceAll(resetStr, "[delete_header]");

            termOutput = termOutput.replaceAll(
                RegExp("([\\s\\S]+?)\[delete_header\]"), "");

            setState(() {});
          }
          if (result == String.fromCharCodes([8, 32, 8])) {
            print("=====>按下删除");
            termOutput = termOutput.substring(0, termOutput.length - 1);
            setState(() {});
          } else {
            if (result.startsWith(String.fromCharCode(8)) &&
                result[1] != String.fromCharCode(8) &&
                termOutput.isNotEmpty) {
              termOutput = termOutput.substring(0, termOutput.length - 1);
              result = result.replaceFirst(String.fromCharCode(8), "");
            }
            while (Utf8Codec().encode(result).contains(8)) {
              // termOutput = termOutput.substring(0, out.length - 1);
              cursor++;
              result = result.replaceFirst(String.fromCharCode(8), "");
              setState(() {});
            }
            if (result == String.fromCharCode(7)) {
              //没有内容可以删除时，会输出‘\b’，它提示终端发出蜂鸣的声音以来提示用户
              // print("别删了");
            } else if (result.contains("Nightmare_exit_true")) {
              result = result.replaceAll(
                  RegExp("Nightmare_exit_true|echo Nightmare_exit_true"), "");
              showToast2("执行结束");
              popbool = true;
            }
            // print(result);
            if (result.contains(RegExp("apktoolFunc|baksmaliFunc|smaliFunc"))) {
              List resultList = result.trim().split("\n");
              print("result====>$result");
              for (String line in resultList) {
                if (line
                    .startsWith(RegExp("apktoolFunc|baksmaliFunc|smaliFunc"))) {
                  result = result.replaceAll(
                      RegExp("apktoolFunc|baksmaliFunc|smaliFunc"), "");
                  //域内都是apktool相关的方法
                  // print("line===>$line");
                  List args = line
                      .replaceAll(
                          RegExp("apktoolFunc|baksmaliFunc|smaliFunc"), "")
                      .trim()
                      .split(" ");
                  // print(args);
                  // resultList.remove(line);
                  // result=resultList.join("\n");

                  String _logpath = getExecTmpFilePath();
                  if (line.startsWith("apktoolFunc")) {
                    apktoolFuncMap("apktool")(_logpath, args).whenComplete(() {
                      Future.delayed(
                        Duration(milliseconds: 10),
                        () {
                          File(_logpath).delete();
                        },
                      );
                    });
                  } else if (line.startsWith("baksmaliFunc")) {
                    apktoolFuncMap("baksmali")(_logpath, args).whenComplete(() {
                      Future.delayed(
                        Duration(milliseconds: 10),
                        () {
                          File(_logpath).delete();
                        },
                      );
                    });
                  }
                  String oldtxt = ""; //历史输出
                  while (!File(_logpath).existsSync())
                    await Future.delayed(Duration());
                  while (File(_logpath).existsSync()) {
                    //如果缓存日志还没有被删除
                    String _termOutputput = "";
                    try {
                      _termOutputput = await File(_logpath).readAsString();
                    } catch (e) {}
                    if (_termOutputput != oldtxt) {
                      //如果缓存日志有新的内容
                      termOutput += _termOutputput.replaceAll(oldtxt, "");
                      setState(() {});
                      // File(Niterm.ptsPaths[0])
                      //     .writeAsStringSync(_termOutputput.replaceAll(oldtxt, ""));
                    }
                    await Future.delayed(Duration(microseconds: 100));
                    oldtxt = _termOutputput;
                    setState(() {});
                    scrollController
                        .jumpTo(scrollController.position.maxScrollExtent);
                    Future.delayed(Duration(milliseconds: 300), () {
                      scrollController
                          .jumpTo(scrollController.position.maxScrollExtent);
                    });
                  }
                  writeToFd(Niterm.terms.first.ptm, Utf8.toUtf8("\n"));
                } else {
                  termOutput += line + "\n";
                  if (mounted) {
                    setState(() {});
                    scrollController
                        .jumpTo(scrollController.position.maxScrollExtent);
                    Future.delayed(Duration(milliseconds: 300), () {
                      scrollController
                          .jumpTo(scrollController.position.maxScrollExtent);
                    });
                  }
                }
              }
              // resultList.removeWhere((a) {
              //   return a.startsWith("apktoolFunc");
              // });
              result = "";
            }
            termOutput += result.replaceAll("\r", "");
            // }
            if (mounted) {
              setState(() {});
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
              Future.delayed(Duration(milliseconds: 300), () {
                scrollController
                    .jumpTo(scrollController.position.maxScrollExtent);
              });
            }
          }
        }
        free(resultPoint);
        await Future.delayed(Duration(milliseconds: 10));
      }
      termOutput = "";
    });
  }

  @override
  void dispose() {
    print("Niterm被销毁");
    writeToFd(Niterm.terms.first.ptm, Utf8.toUtf8(String.fromCharCode(3)));
    Future.delayed(Duration(seconds: 1), () {
      getOutFromFd(Niterm.terms.first.ptm);
    });
    super.dispose();
  }

  @override
  void didUpdateWidget(Niterm oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didUpdateWidget(oldWidget);
  }

  void _onAfterRendering(Duration timeStamp) {
    Future.delayed(Duration(seconds: 1), () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    // File("$documentsDir/MToolkit/日志文件夹/termOutput.txt")
    //     .writeAsStringSync(termOutput);
    // termOutput+="⢿";
    // print(utf8.encode("⢿"));
    listSpan = [];
    TextStyle textStyle = TextStyle(
      fontSize: 12.0,
      fontFamily: Platform.isLinux ? "NotoSansCJK-Regular" : null,
    );
    for (String a in termOutput.split(String.fromCharCodes([27, 91]))) {
      // print(a);
      if (a.startsWith(RegExp("[0-9]*;"))) {
        RegExp regExp = RegExp("[0-9]*;[0-9]*m");
        String header = regExp.firstMatch(a).group(0);
        String colorNumber = header.split(";")[1];
        if (colorNumber == "34m")
          listSpan.add(
            TextSpan(
                text: a.replaceAll(header, ""),
                style: textStyle.copyWith(
                  color: Colors.lightBlue,
                  decoration: TextDecoration.none,
                )),
          );
        else if (colorNumber == "31m")
          listSpan.add(
            TextSpan(
              text: a.replaceAll(header, ""),
              style: textStyle.copyWith(color: Color(0xffff0000)),
            ),
          );
        else if (colorNumber == "32m")
          listSpan.add(
            TextSpan(
              text: a.replaceAll(header, ""),
              style: textStyle.copyWith(color: Colors.lightGreenAccent),
            ),
          );
        else if (colorNumber == "36m")
          listSpan.add(
            TextSpan(
              text: a.replaceAll(header, ""),
              style: textStyle.copyWith(color: Colors.greenAccent),
            ),
          );
        else if (colorNumber == "37m")
          listSpan.add(
            TextSpan(
              text: a.replaceAll(header, ""),
              style: textStyle.copyWith(),
            ),
          );
        else if (colorNumber == "0m")
          listSpan.add(
            TextSpan(
              text: a.replaceAll(header, ""),
              style: textStyle.copyWith(color: Colors.white),
            ),
          );
      } else {
        listSpan.add(
          TextSpan(
            text: a.replaceAll(RegExp("^[0-9]*m"), ""),
            style: textStyle.copyWith(color: Colors.white),
          ),
        );
      }
    }
    int start = listSpan.length - 1;
    while (true) {
      String text = listSpan[start].toPlainText();
      if (text.length > cursor) {
        if (cursor == 0) {
          listSpan.add(
            TextSpan(
              text: "  ",
              style: listSpan[start].style.copyWith(
                    backgroundColor: Colors.grey,
                  ),
            ),
          );
          break;
        }
        String header = text.substring(0, text.length - cursor);
        // print(header);
        String tail = text.substring(text.length - cursor + 1, text.length);
        // print(tail);
        String cursorStr = text[text.length - cursor];
        // print("cursorStr===>$cursorStr");
        listSpan[start] = TextSpan(
          style: listSpan[start].style,
          text: header,
          children: [
            TextSpan(
              text: cursorStr,
              style: listSpan[start].style.copyWith(
                    backgroundColor: Colors.grey,
                  ),
            ),
            TextSpan(
              text: tail,
            ),
          ],
        );
      }
      break;
    }
    // print(utf8.decode([0x3e]));
    // listSpan.add(TextSpan(

    //   text: "⢿",
    //   style: TextStyle(

    //   fontFamily: Platform.isLinux ? "Roboto" : null,
    //   )
    // ));
    return WillPopScope(
      onWillPop: () async {
        if (!popbool) {
          showToast2("返回键已拦截，请等待释放");
        }
        return popbool;
      },
      child: MaterialApp(

        debugShowCheckedModeBanner: false,
        title: "Niterm",
        theme: ThemeData(
          fontFamily: Platform.isLinux ? "NotoSansCJK-Regular" : null,
          primaryColorBrightness: Brightness.dark,
          accentColorBrightness: Brightness.dark,
        ),
        home: Scaffold(
          primary: !widget.showOnDialog,
          appBar: PreferredSize(
            child: AppBar(
              primary: !widget.showOnDialog,
              centerTitle: true,
              backgroundColor: Colors.black,
              title: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Niterm",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            preferredSize: Size.fromHeight(24),
          ),
          resizeToAvoidBottomPadding: widget.showOnDialog ? false : true,
          backgroundColor: Colors.black,
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              buildSafeArea(context),
              buildButton(context),
            ],
          ),
        ),
      ),
    );
  }

  SafeArea buildButton(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: SizedBox(
                  height: 30,
                  width: 60.0,
                  child: Center(
                    child: Text(
                      "ESC",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  isUseCtrl = !isUseCtrl;
                  setState(() {});
                  // writeToFd(Niterm.terms.first,
                  //     Utf8.toUtf8(String.fromCharCode(3)));
                },
                child: SizedBox(
                  height: 30,
                  width: 60.0,
                  child: Center(
                    child: Text(
                      "CTRL",
                      style: TextStyle(
                          color: isUseCtrl ? Colors.blueAccent : Colors.white),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  cursor--;
                  setState(() {});
                },
                child: SizedBox(
                  height: 30,
                  width: 60.0,
                  child: Center(
                    child: Text(
                      "ALT",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  writeToFd(Niterm.terms.first.ptm,
                      Utf8.toUtf8(String.fromCharCode(3)));
                },
                child: SizedBox(
                  height: 30,
                  width: 60.0,
                  child: Center(
                    child: Text(
                      "-",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SafeArea buildSafeArea(BuildContext context) {
    return SafeArea(
      top: !widget.showOnDialog,
      child: GestureDetector(
        onTap: () async {
          // if (!widget.showOnDialog) {
          print("object");
          focusNode.unfocus();
          await Future.delayed(Duration(milliseconds: 0));
          FocusScope.of(context).requestFocus(focusNode);
          // }
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        },
        onLongPress: () {},
        onLongPressEnd: (details) {
          Feedback.forLongPress(context);
          OverlayEntry overlayEntry;
          overlayEntry = OverlayEntry(
            builder: (context) {
              //外层使用Positioned进行定位，控制在Overlay中的位置
              return Positioned(
                top: details.globalPosition.dy,
                left: details.globalPosition.dx - 60,
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
                      child: FlatButton(
                        onPressed: () async {
                          String b =
                              (await Clipboard.getData("text/plain")).text;
                          writeToFd(Niterm.terms.first.ptm, Utf8.toUtf8(b));
                          overlayEntry.remove();
                        },
                        child: Text("粘贴"),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
          Overlay.of(context).insert(overlayEntry);
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: 40.0),
          child: ListView(
            controller: scrollController,
            cacheExtent: 10000,
            padding: EdgeInsets.only(left: 2, bottom: 0.0, top: 0.0),
            children: <Widget>[
              // Align(
              //   alignment: Alignment.topCenter,
              //   child: Text(
              //     "Niterm",
              //     style: TextStyle(color: Colors.white),
              //   ),
              // ),
              // RawKeyboardListener(
              //   focusNode: focusNode,
              //   child: SizedBox(),
              //   onKey: (key){
              //     print(key);
              //   },
              // ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 12.0, fontFamily: "NotoSansCJK-Regular"),
                  children: listSpan +
                      [
                        // if (cursor == 0)
                        //   TextSpan(
                        //     text: "⢿",
                        //     style: TextStyle(
                        //         backgroundColor: Colors.grey,
                        //         fontSize: 12.0,
                        //         fontFamily: "NotoSansCJK-Regular"),
                        //   ),
                      ],
                ),
              ),

              SizedBox(
                height: 60.0,
                child: TextField(
                  controller: editingController,
                  autofocus: widget.showOnDialog ? false : true,
                  keyboardType: TextInputType.text,
                  focusNode: focusNode,
                  style: TextStyle(color: Colors.transparent),
                  cursorColor: Colors.transparent,
                  showCursor: true,
                  cursorWidth: 0,
                  enabled: true,
                  scrollPadding: EdgeInsets.all(0.0),
                  enableInteractiveSelection: false,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                    // hasFloatingPlaceholder: false,
                  ),
                  onChanged: (strCall) {
                    // print(editingController.selection.end);
                    // print(strCall);
                    String currentInput =
                        strCall[editingController.selection.end-1];
                    print(currentInput);
                    if (strCall.length > textTmp.length) {
                      if (isUseCtrl) {
                        writeToFd(
                            Niterm.terms.first.ptm,
                            Utf8.toUtf8(String.fromCharCode(strCall
                                    .replaceAll(textTmp, "")
                                    .toUpperCase()
                                    .codeUnits[0] -
                                64)));

                        isUseCtrl = false;
                        setState(() {});
                      } else {
                        writeToFd(Niterm.terms.first.ptm,
                            Utf8.toUtf8(currentInput));
                      }
                    } else {
                      writeToFd(Niterm.terms.first.ptm,
                          Utf8.toUtf8(String.fromCharCode(127)));
                    }
                    textTmp = strCall;
                  },
                  onEditingComplete: () {
                    cursor = 0;
                  },
                  onSubmitted: (a) {
                    // editingController.clear();
                    // print("sdasdd");
                    // print(utf8.encode("\n"));
                    editingController.clear();
                    writeToFd(Niterm.terms.first.ptm, Utf8.toUtf8("\n"));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

import 'term_func.dart';

class Niterm extends StatefulWidget {
  final String script;
  final bool showOnDialog;
  const Niterm({Key key, this.script, this.showOnDialog = false})
      : super(key: key);
  static List<int> terms = [];
  static List<int> tmp = []; //这个缓存是为了解决拿到的最后字符不完整
  static void creatNewTerm() async {
    var path = 'libterm.so';
    if (Platform.isMacOS) {
      path =
          "/Users/nightmare/Library/Containers/com.nightmareTool/Data/libterm.dylib";
    }
    final dylib = DynamicLibrary.open(path);
    //等价于  char **argv;

    final getPtmIntPointer =
        dylib.lookup<NativeFunction<get_ptm_int>>('get_ptm_int');
    final GetPtmInt getPtmInt = getPtmIntPointer.asFunction<GetPtmInt>();
    int currentPtm = getPtmInt(200, 200);
    terms.add(currentPtm);
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
        "/data/data/com.nightmare/files/usr/bin:" + environment["PATH"];
    envp = allocate(count: environment.keys.length + 1);
    for (int i = 0; i < environment.keys.length; i++) {
      envp[i] = Utf8.toUtf8(
          "${environment.keys.elementAt(i)}=${environment[environment.keys.elementAt(i)]}");
    }
    envp[environment.keys.length] = Pointer.fromAddress(0);
    Pointer<Int32> p = allocate();
    p.value = 0;
    createSubprocess(
        Utf8.toUtf8(''),
        Utf8.toUtf8('/system/bin/sh'),
        Utf8.toUtf8('/data/data/com.nightmare/files/home'),
        argv,
        envp,
        p,
        currentPtm);
    print(p.value);
    free(p);
  }

  static String cStringtoString(Pointer<Uint8> str) {
    if (str == null) {
      return null;
    }
    int len = 0;
    while (str.elementAt(++len).value != 0) {}
    List<int> units = List(len);
    for (int i = 0; i < len; ++i) units[i] = str.elementAt(i).value;
    units = Niterm.tmp + units;
    len = len + Niterm.tmp.length;
    Niterm.tmp.clear();
    //只有当为0开头经过二进制转换才小于7位，如果读取到的最后一个字符为0开头，
    //说明这整个UTF8字符占用1个字节，不存在后面还有其他字节没有读取到的情况
    if (units[len - 1].toRadixString(2).length <= 7) {
      try {
        return Utf8Codec().decode(units, allowMalformed: true);
      } catch (e) {
        print(e);
      }
    } else {
      int number = 0;
      while (true) {
        if (units[len - 1 - number].toRadixString(2).startsWith("10")) {
          //经过一次10开头的便记录一次
          number++;
        } else if (units[len - 1 - number]
            .toRadixString(2)
            .startsWith("1" * (number + 2))) {
          //此时该字节以number+2个字节开始，说明该次读取不完整
          //因为此时该字节开始的1应该为number+1个(10开始的个数加上此时这个字节)
          Niterm.tmp = units.sublist(len - number - 1);
          units.removeRange(len - number - 1, len);
          break;
        } else
          break;
      }
    }
    return Utf8Codec().decode(units, allowMalformed: true);
  }

  static exec(String script) {
    var path = 'libterm.so';
    if (Platform.isMacOS) {
      path =
          "/Users/nightmare/Library/Containers/com.nightmareTool/Data/libterm.dylib";
    }
    final dylib = DynamicLibrary.open(path);
    final writetofdpointer =
        dylib.lookup<NativeFunction<write_to_fd>>('write_to_fd');
    WriteToFd writeToFd = writetofdpointer.asFunction();
    writeToFd(Niterm.terms.first, Utf8.toUtf8(script));
  }

  static getOutPut(BuildContext context, void Function(String line) callBack) {
    bool exit = false;
    var path = 'libterm.so';
    if (Platform.isMacOS) {
      path =
          "/Users/nightmare/Library/Containers/com.nightmareTool/Data/libterm.dylib";
    }
    final dylib = DynamicLibrary.open(path);
    final getOutFromFdPointer =
        dylib.lookup<NativeFunction<get_output_from_fd>>('get_output_from_fd');
    GetOutFromFd getOutFromFd = getOutFromFdPointer.asFunction();
    Future.delayed(
      Duration(seconds: 1),
      () async {
        while (!exit && Niterm.terms.isNotEmpty) {
          // Utf8.fromUtf8(string)
          Pointer resultPoint = getOutFromFd(Niterm.terms.first);
          if (resultPoint.address != 0) {
            String result = "";
            try {
              result = Niterm.cStringtoString(resultPoint);
            } catch (e) {
              print("转换出错=====>$e");
            }
            if (result.startsWith("\b")) {
            } else if (result.codeUnits == [7]) {
            } else {
              // if(result)
              if (context.findRenderObject().attached) {
                callBack(result);
              } else {
                Future.delayed(Duration(seconds: 1), () {
                  exit = true;
                });
              }
            }
            // print(out);
          }
          free(resultPoint);
          await Future.delayed(Duration(microseconds: 0));
        }
      },
    );
  }

  @override
  _NitermState createState() => _NitermState();
}

class _NitermState extends State<Niterm> {
  bool showOutPut = true;
  int cursor = 0;
  bool isUseCtrl = false;
  List<InlineSpan> listSpan = [];
  String ptsPath = "";
  String out = "";
  Process process;
  WriteToFd writeToFd;
  GetOutFromFd getOutFromFd;
  bool popbool; //禁止返回
  @override
  void initState() {
    super.initState();
    init();
  }

  List listCommond = [
    "unZipRom",
    "unZipBrsystem",
    "sdat2imgsystem",
    "unZipImgsystem",
    "unZipBrvendor",
    "sdat2imgvendor",
    "unZipImgvendor",
    "deodexFunc",
    "deleteAd",
    "repackImg",
    "img2sdatsystem",
    "img2sdatvendor",
    "unpackBoot",
    "deleteAvb",
    "doPermissive",
    "repackBoot",
  ];
  ptm() async {}
  init() async {
    //设置so库等的路径
    // if (widget.script != null) {
    //   showOutPut = false;
    // }
    popbool = widget.showOnDialog ? false : true;
    // forcePop=widget.showOnDialog?false;
    var path = 'libterm.so';
    if (Platform.isMacOS) {
      path =
          "/Users/nightmare/Library/Containers/com.nightmareTool/Data/libterm.dylib";
    }
    final dylib = DynamicLibrary.open(path);
    final getOutFromFdPointer =
        dylib.lookup<NativeFunction<get_output_from_fd>>('get_output_from_fd');
    getOutFromFd = getOutFromFdPointer.asFunction();
    final writetofdpointer =
        dylib.lookup<NativeFunction<write_to_fd>>('write_to_fd');
    writeToFd = writetofdpointer.asFunction();
    //如果传进来了自动执行的命令
    if (widget.script != null) {
      Future.delayed(
        Duration(milliseconds: 0),
        () async {
          for (String line in widget.script.trim().split("\n")) {
            if (!mounted) break;
            if (line.contains(RegExp("\\[console:.*\\]"))) {
              //如果是特定字符串需要解析
              String _exec = line.replaceAll(RegExp("\\[|\\]|console:"), "");
              writeToFd(Niterm.terms.first, Utf8.toUtf8("echo $_exec\n"));
              while (!out.contains(_exec)) {
                await Future.delayed(Duration(milliseconds: 100));
              }
              // await functionMap[_exec]();
            } else {
              writeToFd(Niterm.terms.first, Utf8.toUtf8(line + "\n"));
              if (listCommond.contains(line)) {
                while (true) {
                  await Future.delayed(Duration(milliseconds: 100));
                  if (!out.endsWith("\$ ") || !out.endsWith("\# ")) break;
                }
                while (true) {
                  await Future.delayed(Duration(milliseconds: 100));
                  if (out.endsWith("\$ ") || out.endsWith("\# ")) break;
                }
              }
              if (line == "su")
                await Future.delayed(Duration(milliseconds: 1000));
            }
          }
        },
      );
      // await Future.delayed(Duration(milliseconds: 200));
      String tmp = ""; //用来累加缓冲前的内容
      while (mounted && Niterm.terms.isNotEmpty) {
        Pointer<Uint8> resultPoint = getOutFromFd(Niterm.terms.first);
        if (resultPoint.address != 0) {
          print("tmp=====>$tmp");
          tmp += Niterm.cStringtoString(resultPoint);
          if (tmp.contains("Nightmare_start")) {
            out = tmp.replaceAll(
                RegExp("([\\s\\S]+?).*Nightmare_start|.*Nightmare_start"), "");
            setState(() {});
            break;
          }
        }
        free(resultPoint);
        await Future.delayed(Duration(milliseconds: 0));
      }
    }

    Future.delayed(Duration(seconds: 1), () async {
      while (mounted && Niterm.terms.isNotEmpty) {
        // Utf8.fromUtf8(string)
        Pointer<Uint8> resultPoint = getOutFromFd(Niterm.terms.first);
        if (resultPoint.address != 0) {
          for (int i = 0; i < cursor; i++) {
            out = out.substring(0, out.length - 1);
          }
          cursor = 0;
          String result = "";
          try {
            result = Niterm.cStringtoString(resultPoint);
          } catch (e) {
            //以防万一不能转换
            print("转换出错=====>$e");
          }
          print("codeUnits===》${Utf8Codec().encode(result)}");
          print(result);
          // print();
          if (result ==
              Utf8Codec().decode([
                27,
                99,
                27,
                40,
                66,
                27,
                91,
                109,
                27,
                91,
                74,
                27,
                91,
                63,
                50,
                53,
                104
              ])) {
            out = "";
            setState(() {});
          } else if (result == String.fromCharCodes([8, 32, 8])) {
            print("=====>按下删除");
            out = out.substring(0, out.length - 1);
            setState(() {});
          } else {
            if (result.startsWith(String.fromCharCode(8)) &&
                result[1] != String.fromCharCode(8) &&
                out.isNotEmpty) {
              out = out.substring(0, out.length - 1);

              result = result.replaceFirst(String.fromCharCode(8), "");
            }
            while (Utf8Codec().encode(result).contains(8)) {
              // out = out.substring(0, out.length - 1);
              cursor++;
              result = result.replaceFirst(String.fromCharCode(8), "");
              setState(() {});
            }
            if (result == String.fromCharCode(7)) {
              //没有内容可以删除时，会输出‘\b’，它提示终端发出蜂鸣的声音以来提示用户
              print("别删了");
            } else if (showOutPut) {
              if (result.contains("Nightmare_exit_true")) {
                result = result.replaceAll("Nightmare_exit_true", "");
                // showToast2("执行结束");
                popbool = true;
              }
              out += result;
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
        }
        free(resultPoint);
        await Future.delayed(Duration(microseconds: 0));
      }
      out = "";
    });
  }

  @override
  void dispose() {
    print("Niterm被销毁");
    writeToFd(Niterm.terms.first, Utf8.toUtf8(String.fromCharCode(3)));
    Future.delayed(Duration(seconds: 1), () {
      getOutFromFd(Niterm.terms.first);
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

  TextEditingController editingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String str = "";
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    // cursor=0;
    // print(cursor);
    // out += " ";
    // out = out.replaceRange(out.length - cursor - 1, out.length - cursor, "光标");
    listSpan = [];
    TextStyle textStyle = TextStyle(fontSize: 12.0);
    for (String a in out.split(String.fromCharCodes([27, 91]))) {
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
    // listSpan.add(
    //   TextSpan(
    //     text: " ",
    //     style: TextStyle(backgroundColor: Colors.grey,fontSize: 12.0),
    //   ),
    // );
    // if (cursor != 0) {
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
    // }
    // listSpan.add(
    //   TextSpan(
    //     text: "  ",
    //     style: textStyle.copyWith(backgroundColor: Colors.grey),
    //   ),
    // );
    return WillPopScope(
      onWillPop: () async {
        if (!popbool) {
          // showToast2("返回键已拦截，请等待释放");
        }
        return popbool;
      },
      child: MaterialApp(
        home: Scaffold(
          // appBar: AppBar(
          //   title: Text("Niterm"),
          // ),
          resizeToAvoidBottomPadding: widget.showOnDialog ? false : true,
          backgroundColor: Colors.black,
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Niterm",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              buildSafeArea(context),
              SafeArea(
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
                                    color: isUseCtrl
                                        ? Colors.blueAccent
                                        : Colors.white),
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
                            writeToFd(Niterm.terms.first,
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
              )
            ],
          ),
        ),
      ),
    );
  }

  SafeArea buildSafeArea(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () async {
          focusNode.unfocus();
          FocusScope.of(context).requestFocus(focusNode);
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
                          writeToFd(Niterm.terms.first, Utf8.toUtf8(b));
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
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  children: listSpan +
                      [
                        // if (cursor == 0)
                        //   TextSpan(
                        //     text: "  ",
                        //     style: TextStyle(
                        //         backgroundColor: Colors.grey, fontSize: 12.0),
                        //   ),
                      ],
                ),
              ),
              SizedBox(
                height: 4.0,
                child: TextField(
                  controller: editingController,
                  autofocus: widget.showOnDialog ? false : true,
                  keyboardType: TextInputType.text,
                  focusNode: focusNode,
                  style: TextStyle(color: Colors.transparent),
                  cursorColor: Colors.transparent,
                  showCursor: true,
                  cursorWidth: 0,
                  
                  scrollPadding: EdgeInsets.all(0.0),
                  enableInteractiveSelection: false,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                    hasFloatingPlaceholder: false,
                  ),
                  onChanged: (r) {
                    if (r.length > str.length) {
                      if (isUseCtrl) {
                        writeToFd(
                            Niterm.terms.first,
                            Utf8.toUtf8(String.fromCharCode(r
                                    .replaceAll(str, "")
                                    .toUpperCase()
                                    .codeUnits[0] -
                                64)));
                        print(r.replaceAll(str, "").toUpperCase().codeUnits[0] -
                            64);
                        isUseCtrl = false;
                        setState(() {});
                      } else {
                        writeToFd(Niterm.terms.first,
                            Utf8.toUtf8(r.replaceAll(str, "")));
                      }
                    } else {
                      writeToFd(Niterm.terms.first,
                          Utf8.toUtf8(String.fromCharCode(127)));
                    }
                    str = r;
                  },
                  onEditingComplete: () {
                    cursor = 0;
                  },
                  onSubmitted: (a) {
                    writeToFd(Niterm.terms.first, Utf8.toUtf8("\n"));
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

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_toolkit/common/envirpath.dart';
import 'package:flutter_toolkit/utils/apktool_func.dart';
import 'package:flutter_toolkit/utils/platform_channel.dart';

import 'term.dart';

typedef create_subprocess = Void Function(
    Pointer<Utf8> env,
    Pointer<Utf8> cmd,
    Pointer<Utf8> cwd,
    Pointer<Pointer<Utf8>> argv,
    Pointer<Pointer<Utf8>> envp,
    Pointer<Int32> pProcessId,
    Int32 ptmfd);
typedef CreateSubprocess = void Function(
    Pointer<Utf8> env,
    Pointer<Utf8> cmd,
    Pointer<Utf8> cwd,
    Pointer<Pointer<Utf8>> argv,
    Pointer<Pointer<Utf8>> envp,
    Pointer<Int32> pProcessId,
    int ptmfd);

typedef create_ptm = Int32 Function(Int32 row, Int64 column);

typedef CreatePtm = int Function(int row, int column);

typedef get_output_from_fd = Pointer<Uint8> Function(Int32);
typedef GetOutFromFd = Pointer<Uint8> Function(int);

typedef write_to_fd = Void Function(Int32, Pointer<Utf8>);
typedef WriteToFd = void Function(int, Pointer<Utf8>);

typedef getfilepath = Pointer<Utf8> Function(Int32 fd);
typedef GetFilePathFromFdDart = Pointer<Utf8> Function(int fd);
Future<void> Function(String path, List<String> args) apktoolFuncMap(String key) {
  if (key == "apktool") return apktoolFunc;
  if (key == "baksmali") return baksmaliFunc;
  return null;
}

Future<void> apktoolFunc(String path, List<String> args) async {
  await setOutputFile(path);
  await PlatformChannel.Decompile.invokeMethod("apktool", args);
}
Future<void> baksmaliFunc(String path, List<String> args) async {
  await setOutputFile(path);
  await PlatformChannel.Decompile.invokeMethod("baksmali", args);
}
defineTermFunc(String func) async {
  print("定义函数中...");
  String cache = "";
  Niterm.getOutPut((output) async {
    cache += output;
    print("output=====>$output");
    if (output.contains("define_func_finish")) {
      return true;
    } else
      return false;
  });
  print("创建临时脚本...");
  await File("${EnvirPath.binPath}/sprintf").writeAsString(func);
  Niterm.exec(
      "source ${EnvirPath.binPath}/sprintf\nrm -rf ${EnvirPath.binPath}/sprintf\necho 'define_func_finish'\n");
  while (!cache.contains("define_func_finish")) {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

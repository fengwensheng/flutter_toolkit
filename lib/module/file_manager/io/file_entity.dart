import 'dart:io';

import 'package:flutter_toolkit/module/file_manager/io/directory.dart';
import 'package:flutter_toolkit/module/file_manager/io/file.dart';

abstract class FileEntity {
  //这个名字可能带有->/x/x的字符
  String path;
  //完整信息
  String fullInfo;
  //文件创建日期

  String accessed = "";
  //文件修改日期
  String modified = "";
  //如果是文件夹才有该属性，表示它包含的项目数
  String itemsNumber = "";
  // 节点的权限信息
  String mode = "";
  // 文件的大小，isFile为true才赋值该属性
  String size = "";
  String uid = "";
  String gid = "";
  String get nodeName => path.split(" -> ").first.split("/").last;
  bool get isFile => this.runtimeType == NiFile;
  bool get isDirectory => this.runtimeType == NiDirectory;
  static final List<String> imagetype = ["jpg", "png"]; //图片的所有扩展名
  static final List<String> textType = [
    "smali",
    "txt",
    "xml",
    "py",
    "sh",
    "dart"
  ]; //文本的扩展名
  static bool isText(FileEntity fileNode) {
    String type = fileNode.nodeName.replaceAll(RegExp(".*\\."), "");
    print(type);
    return textType.contains(type);
  }

  static bool isImg(FileEntity fileNode) {
  // Directory();
  // File
    String type = fileNode.nodeName.replaceAll(RegExp(".*\\."), "");
    print(type);
    return imagetype.contains(type);
  }
}

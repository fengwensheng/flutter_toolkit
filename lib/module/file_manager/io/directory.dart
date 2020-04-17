import 'dart:io';

import 'package:flutter_toolkit/utils/process.dart';

import 'file.dart';
import 'file_entity.dart';

class NiDirectory extends FileEntity {
  final String path;

  //如果是文件夹才有该属性，表示它包含的项目数
  String itemsNumber = "";
  String fullInfo;
  NiDirectory.initWithFullInfo(this.path, this.fullInfo);
  NiDirectory(this.path);
  Future<List<FileEntity>> listAndSort() async {
    List<FileEntity> _fileNodes = [];
    String lsPath;
    if (Platform.isAndroid)
      lsPath = "/system/bin/ls";
    else
      lsPath = "ls";
    int _startIndex;
    List<String> _fullmessage = [];
    path = path.replaceAll("//", "/");
    // print("刷新的路径=====>>$path");
    _fullmessage = (await CustomProcess.exec("$lsPath -aog '$path'\n"))
        .split("\n")
          ..removeAt(0);
    String b = "";
    for (int i = 0; i < _fullmessage.length; i++) {
      if (_fullmessage[i].startsWith("l")) {
        //说明这个节点是符号链接
        if (_fullmessage[i].split(" -> ").last.startsWith("/")) {
          //首先以 -> 符号分割开，last拿到的是该节点链接到的那个元素
          //如果这个元素不是以/开始，则该符号链接使用的是相对链接
          b += _fullmessage[i].split(" -> ").last + "\n";
        } else {
          b += "$path/${_fullmessage[i].split(" -> ").last}\n";
        }
      }
    }
    // print("======>$b");
    if (b.isNotEmpty) {
      //-g取消打印owner  -0取消打印group   -L不跟随符号链接，会指向整个符号链接最后指向的那个
      List<String> linkFileNodes =
          (await CustomProcess.exec("echo '$b'|xargs $lsPath -ALdog\n"))
              .replaceAll("//", "/")
              .split("\n");
      print("linkFileNodes=====>$linkFileNodes");
      Map<String, String> map = Map();
      for (String str in linkFileNodes) {
        // print(str);
        map[str.replaceAll(RegExp(".*[0-9] "), "")] = str.substring(0, 1);
      }
      print(map);
      for (int i = 0; i < _fullmessage.length; i++) {
        if (_fullmessage[i].startsWith("l") &&
            map.keys.contains(_fullmessage[i].split(" -> ").last)) {
          print(_fullmessage[i]);
          _fullmessage[i] = _fullmessage[i].replaceAll(
              RegExp("^l"), map[_fullmessage[i].split(" -> ").last]);
          // f.remove(f.first);
        }
      }
      File("/sdcard/MToolkit/日志文件夹/自定义日志.txt")
          .writeAsString(_fullmessage.join("\n"));
    }
    // DateTime three = DateTime.now();
    // print("得到最终的文件列表信息耗时===>>${three.difference(two)}");
    // _fullmessage..toString().re
    _fullmessage.removeWhere((a) {
      //查找.这个所在的行数
      return a.endsWith(" .");
    });
    int currentIndex = _fullmessage.indexWhere((a) {
      return a.endsWith(" ..");
    });
    _startIndex = _fullmessage[currentIndex].indexOf(".."); //获取文件名开始的地址
    // print("startIndex===>>>$_startIndex");
    if (path == "/") {
      //如果当前路径已经是/就不需要再加一个/了
      for (int i = 0; i < _fullmessage.length; i++) {
        FileEntity fileEntity;
        if (_fullmessage[i].startsWith(RegExp("-|l"))) {
          fileEntity = NiFile("$path" + _fullmessage[i].substring(_startIndex),
              _fullmessage[i]);
        } else {
          fileEntity = NiDirectory.initWithFullInfo(
              "$path" + _fullmessage[i].substring(_startIndex),
              _fullmessage[i]);
        }
        _fileNodes.add(fileEntity);
      }
    } else {
      for (int i = 0; i < _fullmessage.length; i++) {
        FileEntity fileEntity;
        if (_fullmessage[i].startsWith(RegExp("-|l"))) {
          fileEntity = NiFile("$path/" + _fullmessage[i].substring(_startIndex),
              _fullmessage[i]);
        } else {
          fileEntity = NiDirectory.initWithFullInfo(
              "$path/" + _fullmessage[i].substring(_startIndex),
              _fullmessage[i]);
        }
        _fileNodes.add(fileEntity);
      }
    }
    _fileNodes.sort((a, b) => fileNodeCompare(a, b));
    return _fileNodes;
  }

  /* */
//文件节点的比较，文件夹在上面
  int fileNodeCompare(FileEntity a, FileEntity b) {
    //在遵循文件夹在上的条件下且按文件名排序
    if (a.isFile && !b.isFile) return 1;
    if (!a.isFile && b.isFile) return -1;
    return a.path.toLowerCase().compareTo(b.path.toLowerCase());
  }
}

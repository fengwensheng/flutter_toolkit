import 'package:flutter_toolkit/module/file_manager/model/file_node.dart';

class FileType {
  final List<String> imagetype = ["jpg", "png"]; //图片的所有扩展名
  static final List<String> textType = [
    "smali",
    "txt",
    "xml",
    "py",
    "sh"
  ]; //文本的扩展名
  static bool isText(FileNode fileNode) {
    String type = fileNode.nodeName.replaceAll(RegExp(".*\\."), "");
    print(type);
    return textType.contains(type);
  }
}

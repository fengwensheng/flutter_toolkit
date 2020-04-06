import 'package:flutter/material.dart';
import 'package:flutter_toolkit/module/file_manager/model/file_node.dart';

enum ClipType {
  Cut,
  Copy,
}

class FiMaPageNotifier extends ChangeNotifier {
  List<FileNode> checkNodes = [];
  List<String> _clipboard = [];
  ClipType _clipType;
  ClipType get clipType => _clipType;
  List<String> get clipboard => _clipboard;
  addCheck(FileNode fileNode) {
    checkNodes.add(fileNode);
  }

  removeCheck(FileNode fileNode) {
    checkNodes.remove(fileNode);
  }
  removeAllCheck() {
    checkNodes.clear();
    notifyListeners();
  }
  setClipBoard(ClipType clipType, String path) {
    print("添加$path到剪切板");
    _clipType = clipType;
    if(!clipboard.contains(path))_clipboard.add(path);
    notifyListeners();
  }

  clearClipBoard() {
    _clipboard = [];
    notifyListeners();
  }
}

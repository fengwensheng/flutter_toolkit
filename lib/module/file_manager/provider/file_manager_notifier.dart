import 'package:flutter/material.dart';
import 'package:flutter_toolkit/module/file_manager/io/file_entity.dart';

enum ClipType {
  Cut,
  Copy,
}

class FiMaPageNotifier extends ChangeNotifier {
  List<FileEntity> checkNodes = [];
  List<String> _clipboard = [];
  ClipType _clipType;
  ClipType get clipType => _clipType;
  List<String> get clipboard => _clipboard;
  addCheck(FileEntity fileNode) {
    checkNodes.add(fileNode);
  }

  removeCheck(FileEntity fileNode) {
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

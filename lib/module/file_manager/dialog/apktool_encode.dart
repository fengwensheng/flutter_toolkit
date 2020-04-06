import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_toolkit/utils/global_function.dart';

import '../../term/term.dart';
import '../model/file_node.dart';

class ApkToolEncode extends StatefulWidget {
  final FileNode fileNode;

  const ApkToolEncode({Key key, @required this.fileNode}) : super(key: key);
  @override
  _ApkToolEncodeState createState() => _ApkToolEncodeState(fileNode);
}

class _ApkToolEncodeState extends State<ApkToolEncode> {
  final FileNode _fileNode;

  _ApkToolEncodeState(this._fileNode);
  Widget apkToolItem(String title, Function onTap) {
    return Material(
      color: Colors.white,
      child: Ink(
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 46,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(_fileNode.nodeName),
        apkToolItem(
          "回编译",
          () {
            Navigator.pop(context);
            showCustomDialog2(
              isPadding: false,
              height: 600.0,
              child: Niterm(
                showOnDialog: true,
                script: "apktool b ${widget.fileNode.path} " +
                    "-f -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/${widget.fileNode.nodeName.replaceAll("_src", "")}_new.apk ",
              ),
            );
          },
        ),
      ],
    );
  }
}

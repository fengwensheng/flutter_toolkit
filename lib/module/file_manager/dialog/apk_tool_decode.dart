import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_toolkit/module/file_manager/io/file.dart';
import 'package:flutter_toolkit/utils/global_function.dart';

import '../../term/term.dart';

class ApkToolDialog extends StatefulWidget {
  final NiFile fileNode;

  const ApkToolDialog({Key key, @required this.fileNode}) : super(key: key);
  @override
  _ApkToolDialogState createState() => _ApkToolDialogState(fileNode);
}

class _ApkToolDialogState extends State<ApkToolDialog> {
  final NiFile _fileNode;

  _ApkToolDialogState(this._fileNode);
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
          "反编译全部",
          () {
            Navigator.pop(context);
            showCustomDialog2(
              isPadding: false,
              height: 600.0,
              child: Niterm(
                showOnDialog: true,
                script: "apktool  d ${widget.fileNode.path} " +
                    "-f -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/${widget.fileNode.nodeName.replaceAll(".apk", "")}_src " +
                    "-p /data/data/com.nightmare/files/Apktool/Framework/",
              ),
            );
          },
        ),
        apkToolItem("反编译dex", () {
           Navigator.pop(context);
            showCustomDialog2(
              isPadding: false,
              height: 600.0,
              child: Niterm(
                showOnDialog: true,
                script: "apktool  d ${widget.fileNode.path} " +
                    "-f -r -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/${widget.fileNode.nodeName.replaceAll(".apk", "")}_src " +
                    "-p /data/data/com.nightmare/files/Apktool/Framework/",
              ),
            );
        }),
        apkToolItem("反编译res", () {
           Navigator.pop(context);
            showCustomDialog2(
              isPadding: false,
              height: 600.0,
              child: Niterm(
                showOnDialog: true,
                script: "apktool  d ${widget.fileNode.path} " +
                    "-f -s -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/${widget.fileNode.nodeName.replaceAll(".apk", "")}_src " +
                    "-p /data/data/com.nightmare/files/Apktool/Framework/",
              ),
            );
        }),
        apkToolItem("签名", () {}),
        apkToolItem("Zipalign", () {}),
        apkToolItem("解压出META-INF", () {}),
        apkToolItem("添加META-INF", () {}),
        apkToolItem("删除dex", () {}),
        apkToolItem("删除META-INF", () {}),
        apkToolItem("导入框架", () {
          Niterm.exec(
              "echo apktool if ${_fileNode.path} -p /data/data/com.nightmare/files/Apktool/Framework");
        }),
      ],
    );
  }
}

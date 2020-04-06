import 'package:flutter/material.dart';
import 'package:flutter_toolkit/main.dart';
import 'package:flutter_toolkit/utils/process.dart';

import '../file_manager.dart';

class AddFileNode extends StatelessWidget {
  final bool isAddFile;
  final String currentPath;

  const AddFileNode({Key key, this.isAddFile, this.currentPath}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();

    return Column(
      children: <Widget>[
        Text(
          "请输入要创建的文件${isAddFile ? "" : "夹"}名称",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        TextField(
          controller: textEditingController,
          decoration: InputDecoration(contentPadding: EdgeInsets.all(0.0)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(globalContext);
                },
                child: Text("取消")),
            FlatButton(
                onPressed: () async {
                  if (isAddFile)
                    await CustomProcess.exec(
                        "touch $currentPath/${textEditingController.text}\n");
                  else {
                    await CustomProcess.exec(
                        "mkdir $currentPath/${textEditingController.text}\n");
                  }
                  eventBus.fire(1);
                  Navigator.pop(context);
                },
                child: Text("确定")),
          ],
        )
      ],
    );
  
  }
}
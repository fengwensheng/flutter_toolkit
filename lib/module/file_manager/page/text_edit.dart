import 'dart:io';

// import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toolkit/module/file_manager/model/file_node.dart';

class TextEdit extends StatefulWidget {
  final FileNode fileNode;

  const TextEdit({Key key, @required this.fileNode}) : super(key: key);

  @override
  _TextEditState createState() => _TextEditState();
}

class _TextEditState extends State<TextEdit> {
  List<String> fileText;
  TextEditingController _textEditingController;
  ScrollController _scrollController;
  ScrollController _scrollController0;
  int maxLength = 0;

  @override
  void initState() {
    super.initState();
    initText();
  }

  initText() {
    _scrollController = ScrollController()
      ..addListener(() {
        _scrollController0.jumpTo(_scrollController.offset);
      });
    _scrollController0 = ScrollController();
    fileText = File(widget.fileNode.path).readAsLinesSync();
    maxLength = fileText.length;
    _textEditingController = TextEditingController(text: fileText.join("\n"));
    //_textEditingController.selection = TextSelection(baseOffset: 0,extentOffset: 0,isDirectional: true);
    print(maxLength);
    print("maxstr");
    setState(() {});
  }

  double onVerticalDragStart = 0.0;
  double onHorizontalDragStart;
  Matrix4 matrix4;
  double current = 0.0;
  double _scale = 1.0;
  double _tmpScale = 1.0;
  double _fontSize = 16;
  double _tmpfontSize = 16;

  @override
  Widget build(BuildContext context) {
    Matrix4 matrix4 = Matrix4.identity()..scale(_scale, _scale);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileNode.nodeName,
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: GestureDetector(
          onScaleStart: (details) {
            onVerticalDragStart =
                details.localFocalPoint.dy + _scrollController.offset;
            // _tmpScale = _scale;
            _tmpfontSize = _fontSize;
            // print(onVerticalDragStart);
          },
          // onPanUpdate: ,
          onScaleUpdate: (details) {
            // print(_scrollController.offset);
            print(details.localFocalPoint.dy);
            if (details.scale == 1.0) {
              _scrollController
                  .jumpTo(onVerticalDragStart - details.localFocalPoint.dy);
            } else {
              //_scale = _tmpScale * details.scale;
              _fontSize = _tmpfontSize * details.scale;
            }

            setState(() {});
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 25,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _scrollController0,
                  itemCount: fileText.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (BuildContext context, int index) {
                    return Material(
                      color: Colors.grey[200],
                      child: Text(
                        "$index",
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 2000,
                child: Scrollbar(
                  child: TextField(
                    scrollController: _scrollController,
                    scrollPhysics: NeverScrollableScrollPhysics(),
                    onTap: null,
                    onChanged: (a) {},
                    style: TextStyle(fontSize: _fontSize),
                    keyboardType: TextInputType.multiline,
                    controller: _textEditingController,
                    maxLines: 100,
                    //expands: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: Colors.white10,
                        filled: true,
                        contentPadding: const EdgeInsets.only(bottom: 20)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

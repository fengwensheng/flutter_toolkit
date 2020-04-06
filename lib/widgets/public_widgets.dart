import 'package:flutter/material.dart';
import 'package:flutter_toolkit/main.dart';

import 'custom_dialog.dart';

class PopButton extends StatelessWidget {
  final BuildContext popContext;

  const PopButton({Key key, this.popContext}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
      height: 36,
      width: 36,
      child: InkWell(
        // highlightColor: C,
        borderRadius: BorderRadius.circular(25),
        child: const Icon(Icons.arrow_back),
        onTap: () {
          Navigator.of(popContext).pop();
        },
      ),
    );
  }
}

class MaterialClipRRect extends StatefulWidget {
  final Widget child;
  final Function onTap;
  const MaterialClipRRect({Key key, this.child, this.onTap}) : super(key: key);
  @override
  _MaterialClipRRectState createState() => _MaterialClipRRectState();
}

class _MaterialClipRRectState extends State<MaterialClipRRect> {
  bool isOnTap = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          // isOnTap = false;
          // setState(() {});
          if (widget.onTap != null) widget.onTap();
        },
        onTapDown: (_) {
          // isOnTap = true;
          setState(() {});
        },
        onTapCancel: () {
          // isOnTap = false;
          setState(() {});
        },
        child: Material(
          color: Theme.of(context).cardColor,
          shadowColor: Colors.grey.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          elevation: isOnTap ? 0.0 : 8.0,
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

Stack changeLog(String str, bool fromDrawer) {
  return Stack(
    children: <Widget>[
      Padding(
        padding: EdgeInsets.only(top: 25.0, bottom: 50.0),
        child: ListView(
          padding: EdgeInsets.only(
            bottom: 50.0
          ),
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Text(
              str,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: Text(
          "更新日志",
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      if (fromDrawer)
        Align(
          alignment: Alignment.bottomRight,
          child: FlatButton(
            child: Text(
              '返回',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              Navigator.of(globalContext).pop();
            },
          ),
        ),
    ],
  );
}

//这个Widget会默认把ListView显示到最大
class FullHeightListView extends StatefulWidget {
  final Widget child;

  const FullHeightListView({Key key, this.child}) : super(key: key);
  @override
  _FullHeightListViewState createState() => _FullHeightListViewState();
}

class _FullHeightListViewState extends State<FullHeightListView> {
  ScrollController _scrollController = ScrollController();
  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  Future<void> _onAfterRendering(Duration timeStamp) async {
    // print(maxScrollExtent);
    // print(_scrollController.position.viewportDimension +
    //     _scrollController.position.maxScrollExtent);
    // print(_scrollController.position.viewportDimension + maxScrollExtent * 2);
    dialogeventBus.fire(Height(_scrollController.position.viewportDimension +
        _scrollController.position.maxScrollExtent));
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // print(_scrollController.position.viewportDimension);
      // print("context:${context.size.height}");
      // print("maxScrollExtent:${_scrollController.position.maxScrollExtent}");
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(cont)
    return SizedBox(
      child: ListView(
        controller: _scrollController,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          widget.child,
        ],
      ),
    );
  }
}

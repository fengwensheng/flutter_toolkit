import 'package:flutter/material.dart';

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
        behavior: HitTestBehavior.translucent,
        onTap: () {
          isOnTap = false;
          setState(() {});
          if (widget.onTap != null) widget.onTap();
        },
        onTapDown: (_) {
          isOnTap = true;
          setState(() {});
        },
        onTapCancel: () {
          isOnTap = false;
          setState(() {});
        },
        child: Material(
          color: Theme.of(context).cardColor,
        shadowColor: Colors.grey.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          elevation: isOnTap ? 0.0 : 4.0,
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

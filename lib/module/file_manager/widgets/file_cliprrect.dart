import 'package:flutter/material.dart';

class FileClipRRect extends StatelessWidget {
  final Widget child;
  final Function onTap;

  const FileClipRRect({Key key, this.child, this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      elevation: 8.0,
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

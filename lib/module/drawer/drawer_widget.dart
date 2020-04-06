import 'package:flutter/material.dart';

Widget itemMore(IconData _icondata, String _str, Function onTap) {
    return InkWell(
      child: SizedBox(
        height: 46,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 22,
              padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
              child: Icon(
                _icondata,
                size: 20.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
              child: Text(
                _str,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      onTap: onTap
    );
  }
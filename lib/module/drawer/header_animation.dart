import 'dart:math';

import 'package:flutter/material.dart';

class HeaderAnimation extends StatefulWidget {
  @override
  _HeaderAnimationState createState() => _HeaderAnimationState();
}

class _HeaderAnimationState extends State<HeaderAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _location;
  List<Color> colors = [
    Color(0xffef92a5),
    Color(0xff73b3fa),
    Color(0xffb4d761),
    Color(0xffcc99fe),
    Color(0xff6d998e),
    Colors.deepPurple,
    Colors.indigo,
  ];
  Color _color;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    _location =
        Tween<double>(begin: 0.0, end: 0.0).animate(_animationController);
    _color = colors[Random().nextInt(6)];
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  Future _onAfterRendering(Duration timeStamp) async {
    //不能用didupdate回调
    //不然每次setstate都会触发
    if (context!=null) {
      await Future.delayed(Duration(milliseconds: 100));
      _location = Tween<double>(
              begin: 0.0,
              end: (MediaQuery.of(context).size.width - 20.0))
          .animate(_animationController);
      _location.addListener(() {
        setState(() {});
      });
      while (mounted) {
        await _animationController.forward();
        _color = colors[Random().nextInt(6)];
        await _animationController.reverse();
        _color = colors[Random().nextInt(6)];
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // matrix4 = Matrix4.identity()..translate(0.0, 0.0);
    // double _dx=;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(
          height: 1.0,
        ),
        Container(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()..translate(_location.value),
          width: 20.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: _color,
            // borderRadius: BorderRadius.only(
            //   topRight: Radius.circular(12),
            //   bottomLeft: Radius.circular(12),
            // ),
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(12)),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_toolkit/main.dart';
import 'package:flutter_toolkit/router/ripple_router.dart';
import 'package:flutter_toolkit/widgets/my_canvas.dart';

class DrawerLogo extends StatefulWidget {
  final Color logoColor;

  const DrawerLogo({Key key, this.logoColor}) : super(key: key);
  @override
  _DrawerLogoState createState() => _DrawerLogoState();
}

class _DrawerLogoState extends State<DrawerLogo>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> turns;
  static double width = 72;
  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1600));
    turns = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    turns.addListener(() {
      setState(() {});
    });
    _animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: turns,
      child: GestureDetector(
        onTapDown: (a) {
          _animationController.stop();
        },
        onTapUp: (a) {
          _animationController.repeat();
        },
        onTap: () {
         
        },
        child: CustomPaint(
          size: Size(
            width,
            width,
          ),
          painter: Logo(color: Theme.of(context).textTheme.body1.color),
        ),
      ),
    );
  }
}

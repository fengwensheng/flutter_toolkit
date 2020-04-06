import 'package:flutter/material.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_toolkit/main.dart';

showCustomDialog(
    BuildContext context, Duration duration, double height, Widget child,
    [bool bval = true, bool ispadding = true, String tag]) {
  // print(tag);
  //if (tag == null) tag = "dialog";
  return showDialog<Null>(
    context: context,
    barrierDismissible: bval, // user must tap button!
    builder: (BuildContext context) {
      return DialogBuilder(
        tag: tag,
        isPadding: ispadding,
        duration: duration,
        height: height,
        child: child,
        actions: <Widget>[],
      );
    },
  );
}

class Height {
  final double height;

  Height(this.height);
}

class DialogBuilder extends StatefulWidget {
  DialogBuilder({
    Key key,
    this.child,
    this.actions,
    this.title,
    this.padding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.duration = const Duration(milliseconds: 1000),
    this.height = 1000,
    this.tag,
    this.isPadding = true,
  }) : super(key: key);

  final Widget child;
  final List<Widget> actions;
  final Widget title;
  final EdgeInsetsGeometry padding;
  final Duration duration;
  final double height;
  final tag;
  final bool isPadding;
  static void changeHeight(double height){
    dialogeventBus.fire(Height(height));
  }
  @override
  State<StatefulWidget> createState() => DialogBuilderState();
}

EventBus dialogeventBus;

class DialogBuilderState extends State<DialogBuilder>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> dialogHeight;
  Animation curve2;
  Key _key;
  String a;

  @override
  void initState() {
    super.initState();
    if (widget.tag != null)
      _key = GlobalObjectKey(widget.tag);
    else
      _key = GlobalKey();
    _animationController =
        new AnimationController(duration: widget.duration, vsync: this);
    curve2 =
        CurvedAnimation(parent: _animationController, curve: Curves.ease);
    dialogHeight = Tween<double>(
      begin: animabval ? 0 : widget.height,
      end: widget.height,
    ).animate(curve2);
    dialogHeight.addListener(() {
      setState(() {});
    });
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  Future<void> _onAfterRendering(Duration timeStamp) async {
    dialogeventBus = EventBus()
      ..on<Height>().listen((event) {
        dialogHeight = Tween<double>(
          begin: dialogHeight.value,
          end: event.height,
        ).animate(curve2);
        if (_animationController != null) {
          _animationController.reset();
          _animationController.forward();
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // dialogeventBus.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      key: _key,
      backgroundColor: Colors.transparent,
      child: Material(
        shadowColor: Theme.of(context).backgroundColor == Colors.black
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.6),
        elevation: 12.0,
        color: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        )),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
          child: Padding(
              padding:
                  widget.isPadding ? EdgeInsets.all(6.0) : EdgeInsets.all(0),
              child: SizedBox(
                height: dialogHeight.value,
                child: widget.child,
              ),
            ),
        ),
      ),
    );
  }
}

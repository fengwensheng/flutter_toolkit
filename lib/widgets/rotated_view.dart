library rotated_view;

import 'dart:async';
import 'dart:math';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:aeyrium_sensor/aeyrium_sensor.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class EventBusRotated {
  final double angle;

  EventBusRotated(this.angle);
}

//这就是一个具有惯性跟阻力的旋转控件
//可以选择使用传感器控制其旋转
//初学者不是很会简化代码
//多多见谅
typedef AngleCallBack = void Function(double angle);
typedef SpeedCallBack = void Function(double angle);

class RotatedView extends StatefulWidget {
  final Widget child; //需要旋转的子控件
  final bool useSensor; //是否使用传感器
  final bool reverse; //是否反向旋转，配合传感器生效
  final bool haveInertia; //是否使用阻尼曲线减速
  final double accelerated;
  final String tag;
  final callback;
  final SpeedCallBack speedCallBack;
  final Function onLongPress;
  final EventBus eventBus;

  const RotatedView(
      {Key key,
      @required this.child,
      this.useSensor = false,
      this.reverse = true,
      this.haveInertia = true,
      this.accelerated = 2,
      this.tag,
      this.callback,
      this.speedCallBack,
      this.onLongPress,
      this.eventBus})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RotatedViewState();
}

class _RotatedViewState extends State<RotatedView>
    with TickerProviderStateMixin {
  EventBus eventBus = new EventBus();
  Vector3 vector3;
  Size size;
  num _sensor;
  double _rotation = 0.0;
  double _tmpRotation = 0.0;
  double _tmp;
  double _t;
  AnimationController _animationController;
  Animation<double> _values;
  Offset _previous;
  Offset _pre;
  double _change;
  bool _syncSensor = false;
  double _v;
  double _v1;
  double _s;
  double _rad;
  Matrix4 matrix4;
  bool _hasListen = false;
  StreamSubscription _streamSubscription;
  var _angelvalue = 0.0;
  Timer timer;

  GlobalObjectKey globalKey;

  @override
  void initState() {
    _animationController ??= AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _t = 0;
    globalKey = GlobalObjectKey(widget.tag);
    if (widget.eventBus != null)
      widget.eventBus.on<EventBusRotated>().listen(
        (event) {
          int _time;
          // if (!_animationController.isAnimating) {
            if(event.angle==3.14)_time=300;
            else if(event.angle==6.28)_time=300;
            else _time=1000;
            _tmpRotation = _angelvalue * pi / 180.0;
            _animationController = AnimationController(
                vsync: this,
                duration:
                    Duration(milliseconds: _time));
            final Animation curve = CurvedAnimation(
                parent: _animationController, curve: Curves.easeOut);
            _values = Tween(begin: 0.0, end: 1.0).animate(curve);
            _animationController.addListener(
              () {
                setState(
                  () {
                    _rotation = _tmpRotation + event.angle * _values.value;
                  },
                );
              },
            );
            _animationController.forward();
          }
        // },
      );
    super.initState();
  }

  void sensorLinsten() {
    _streamSubscription =
        AeyriumSensor.sensorEvents.listen((SensorEvent event) {
      _hasListen = true;
      if (widget.reverse)
        _sensor = event.roll;
      else
        _sensor = -event.roll;
      //保存传感器插件传回来的Z轴的弧度变化
      _animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 100));
      _values = Tween(begin: 0.0, end: 1.0).animate(_animationController);
      //由于传感器数据在刚好超过π时会马上变为负值
      //所以写一下逻辑来避免一些动画过渡的Bug
      if (_sensor.abs() >= pi / 2) {
        //当倾斜弧度的绝对值大于π/2即90°用另一种方法计算当前的偏移位置
        if (_sensor >= 0) {
          _tmp = _angelvalue * pi / 180;
        }
        if (_sensor <= 0) {
          if (_angelvalue == 0.0) {
            _tmp = _angelvalue;
          } else {
            _tmp = _angelvalue * pi / 180 - 2 * pi; //将传感器值处于三四象限为负转化为正
          }
        }
        if (_sensor >= 0 && _tmp >= 0 || _sensor <= 0 && _tmp <= 0) {
          _change = _sensor - _tmp;
        }
        if (_sensor <= 0 && _tmp >= 0) {
          _change = 2 * pi - (_sensor - _tmp);
        }
      } else {
        _tmp = _rotation;
        _change = _sensor - _tmp;
      }
      _animationController.addListener(() {
        setState(() {
          _rotation = _tmp + _change * _values.value;
          //利用动画的值改变控件倾斜的角度
        });
      });
      if (!_animationController.isAnimating) {
        if (_syncSensor) {
          _animationController.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(RotatedView oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didUpdateWidget(oldWidget);
  }

  void _onAfterRendering(Duration timeStamp) {
    //布局构建完成后执行方法
    //只执行一次
    //location(); //获取当前Widget的位置跟大小
    RenderBox renderObject = globalKey.currentContext.findRenderObject();
    //var offset = renderObject.localToGlobal(Offset.zero);
    //print(offset);
    size = globalKey.currentContext.size;
    vector3 = renderObject.getTransformTo(null)?.getTranslation();
    if (widget.useSensor) {
      _syncSensor = true;
    }
  }

  Future<Null> location() async {
    await Future.delayed(Duration(milliseconds: 100), () {
      RenderBox renderObject = globalKey.currentContext.findRenderObject();
      //var offset = renderObject.localToGlobal(Offset.zero);
      //print(offset);
      //size = renderObject.;
      print(size);
      vector3 = renderObject.getTransformTo(null)?.getTranslation();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useSensor) {
      if (!_hasListen) sensorLinsten();
    } else {
      _hasListen = false;
      if (_streamSubscription != null) _streamSubscription.cancel();
    }
    // 配置 Matrix
    matrix4 = Matrix4.identity()..rotateZ(_rotation);
    //每次调用SetState由这个来改变角度
    if (matrix4.entry(1, 0) >= 0 && matrix4.entry(0, 0) >= 0) {
      //第一象限
      _angelvalue = (asin(matrix4.entry(1, 0))) * 180 / pi;
    }
    if (matrix4.entry(1, 0) >= 0 && matrix4.entry(0, 0) <= 0) {
      //第二象限
      _angelvalue = (acos(matrix4.entry(0, 0))) * 180 / pi;
    }
    if (matrix4.entry(1, 0) <= 0 && matrix4.entry(0, 0) <= 0) {
      //第三象限
      _angelvalue = 360 - (acos(matrix4.entry(0, 0))) * 180 / pi;
    }
    if (matrix4.entry(1, 0) < 0 && matrix4.entry(0, 0) > 0) {
      //第四象限
      _angelvalue = 360 - (acos(matrix4.entry(0, 0))) * 180 / pi;
    }
    return Stack(
      children: <Widget>[
        Container(
          child: Center(
            child: Transform(
              key: globalKey,
              alignment: FractionalOffset.center,
              transform: matrix4,
              child: GestureDetector(
                onPanDown: (details) {
                  _syncSensor = !_syncSensor;
                  if (_animationController.isAnimating) {
                    //点击停止上次事件的动画
                    _animationController.dispose();
                  }
                  _tmpRotation = _rotation;
                  double x1 = -(0.5 * size.width +
                      vector3.x -
                      details.globalPosition.dx);
                  double y1 =
                      0.5 * size.height + vector3.y - details.globalPosition.dy;
                  _previous = Offset(x1, y1);
                  //获取控件中心坐标并保存当前初始点击的点相对控件中心的坐标
                },
                onPanUpdate: (details) {
                  setState(
                    () {
                      double x = -(0.5 * size.width +
                          vector3.x -
                          details.globalPosition.dx);
                      double y = 0.5 * size.height +
                          vector3.y -
                          details.globalPosition.dy;
                      double angle1 =
                          atan2(_previous.dx, _previous.dy); //计算初始按下时相对控件中心的弧度值
                      double angle2 = atan2(x, y); //计算初始当前相对控件中心的弧度值
                      double angle3 = angle2 - angle1; //计算弧度值差
                      if (!widget.useSensor) {
                        _animationController = AnimationController(
                            vsync: this, duration: Duration(milliseconds: 800));
                        _values = Tween(begin: 0.0, end: 1.0)
                            .animate(_animationController);
                        if (widget.callback != null)
                          widget.callback(_angelvalue);
                        //widget.callback0(_v);
                        _rotation = _tmpRotation + angle3; //改变当前的Z轴弧度偏移量
                      }
                      _pre = Offset(x, y);
                      //print(angle2);
                    },
                  );
                },
                onPanEnd: (details) {
                  double x = details.velocity.pixelsPerSecond.dx;
                  double y = details.velocity.pixelsPerSecond.dy;
                  //print(details.velocity);
                  double _a = widget.accelerated * pi;
                  //控件的惯性旋转
                  if (_pre.dx >= 0 && _pre.dy >= 0) {
                    _rad = pi / 2 - atan(_pre.dy / _pre.dx);
                    _v1 = y * sin(_rad) + x * cos(_rad);
                  }
                  if (_pre.dx >= 0 && _pre.dy <= 0) {
                    //_rad = -math.atan(_pre.dy / _pre.dx) + math.pi / 2;
                    _rad = -atan(_pre.dy / _pre.dx);
                    _v1 = y * cos(_rad) - x * sin(_rad);
                  }
                  if (_pre.dx <= 0 && _pre.dy <= 0) {
//                      _rad =math.pi + math.pi / 2 - math.atan(_pre.dy / _pre.dx);
                    _rad = pi / 2 - atan(_pre.dy / _pre.dx);
                    _v1 = -y * sin(_rad) - x * cos(_rad);
                  }
                  if (_pre.dx <= 0 && _pre.dy >= 0) {
//                      _rad =math.pi + math.pi / 2 - math.atan(_pre.dy / _pre.dx);
                    _rad = -atan(_pre.dy / _pre.dx);
                    _v1 = -y * cos(_rad) + x * sin(_rad);
                  }
                  _v = _v1 / (0.5 * size.width);
                  _t = (_v / _a);
                  if (_v > 0) {
                    _s = _v * _t - 0.5 * _a * _t * _t;
                  }
                  if (_v < 0) {
                    _s = -_v * _t + 0.5 * _a * _t * _t;
                  }
                  _animationController = AnimationController(
                      vsync: this,
                      duration:
                          Duration(milliseconds: _t.toInt().abs() * 1000));
                  final Animation curve = CurvedAnimation(
                      parent: _animationController, curve: Curves.easeOut);
                  //阻尼曲线
                  if (widget.haveInertia) {
                    _values = Tween(begin: 0.0, end: 1.0).animate(curve);
                  } else {
                    _values = Tween(begin: 0.0, end: 0.0).animate(curve);
                  }
                  _animationController.addListener(
                    () {
                      setState(
                        () {
                          _rotation = _tmpRotation + _s * _values.value;
                          if (widget.callback != null)
                            widget.callback(_angelvalue);
                        },
                      );
                    },
                  );
                  if (!_animationController.isAnimating) {
                    _tmpRotation = _rotation;
                    //_animationController.reset();
                    if (details.velocity.pixelsPerSecond == Offset(0.0, 0.0)) {
                      //避免手指不能绝对的相对屏幕不动加入一个逻辑
                      //避免一些Bug
                    } else {
                      _animationController.forward();
                    }
                  }
                  if (widget.speedCallBack != null) widget.speedCallBack(_v);
                },
                onDoubleTap: () {
                  //双击恢复默认位置
                  _animationController = AnimationController(
                      vsync: this, duration: Duration(seconds: 1));
                  final Animation curve1 = CurvedAnimation(
                      parent: _animationController, curve: Curves.ease);
                  _values = Tween(begin: 1.0, end: 0.0).animate(curve1);
                  _animationController.addListener(
                    () {
                      setState(
                        () {
                          // 通过动画逐帧还原位置
                          //始终选择小弧度恢复原来位置
                          _tmpRotation = _angelvalue * pi / 180;
                          if (_angelvalue <= 180.0) {
                            _rotation = _tmpRotation * _values.value;
                          } else {
                            _rotation =
                                -(2 * pi - _tmpRotation) * _values.value;
                          }
                        },
                      );
                    },
                  );
                  if (!_animationController.isAnimating) {
                    _animationController.reset();
                    _animationController.forward();
                  }
                },
                onLongPress: () {
                  widget.onLongPress();
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

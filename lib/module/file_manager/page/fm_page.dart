import 'dart:io';
import 'dart:ui';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toolkit/main.dart';
import 'package:flutter_toolkit/module/file_manager/dialog/apk_tool_decode.dart';
import 'package:flutter_toolkit/module/file_manager/dialog/apktool_encode.dart';
import 'package:flutter_toolkit/module/file_manager/dialog/long_press.dart';
import 'package:flutter_toolkit/module/file_manager/io/directory.dart';
import 'package:flutter_toolkit/module/file_manager/io/file.dart';
import 'package:flutter_toolkit/module/file_manager/io/file_entity.dart';
import 'package:flutter_toolkit/module/file_manager/provider/file_manager_notifier.dart';
import 'package:flutter_toolkit/utils/global_function.dart';
import 'package:flutter_toolkit/utils/platform_channel.dart';
import 'package:flutter_toolkit/utils/platform_util.dart';
import 'package:flutter_toolkit/utils/process.dart';
import 'package:flutter_toolkit/widgets/public_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../file_manager.dart';
import '../fm_function.dart';
import 'text_edit.dart';

Directory appDocDir;

typedef PathCallback = Future Function(String path);

class EventBusOn {
  final int a;

  EventBusOn(this.a);
}

class FMPage extends StatefulWidget {
  final String initpath; //打开文件管理器初始化的路径
  final bool chooseFile; //是用这个页面选择文件
  final callback; //这个用来返回文件的路径
  final PathCallback pathCallBack;

  const FMPage(
      {Key key,
      this.initpath,
      this.callback,
      this.chooseFile = false,
      this.pathCallBack})
      : super(key: key);

  @override
  _FMPageState createState() => _FMPageState();
}

class _FMPageState extends State<FMPage> with TickerProviderStateMixin {
  String _currentdirectory = ""; //当前所在的文件夹
  List<FileEntity> _fileNodes = []; //保存所有文件的节点
  // List<FileSystemEntity> _list1;
  ScrollController _scrollController = ScrollController(); //列表滑动控制器
  AnimationController _animationController; //动画控制器，用来控制文件夹进入时的透明度
  Animation<double> _opacityTween; //透明度动画补间值
  Map<String, double> _historyOffset = Map(); //记录每一次的浏览位置

  bool listIsBuilding = false;

  @override
  void initState() {
    super.initState();
    initAnimation();
    initFMPage();
  }

  @override
  void didUpdateWidget(FMPage oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didUpdateWidget(oldWidget);
  }

  initAnimation() {
    //初始化动画
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    final Animation curve =
        CurvedAnimation(parent: _animationController, curve: Curves.ease);
    _opacityTween = Tween<double>(begin: 0.0, end: 1.0)
        .animate(curve); //初始化这个动画的值始终为一，那么第一次打开就不会有透明度的变化
    _opacityTween.addListener(() {
      setState(() {});
    });
    _animationController.forward();
  }

  void _onAfterRendering(Duration timeStamp) {
    // final Animation curve =
    //     CurvedAnimation(parent: _animationController, curve: Curves.ease);
    // _opacityTween = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _historyOffset.forEach((key, value) {
      print(value);
      if (key == _currentdirectory) {
        _scrollController.jumpTo(value);
        // _scrollController.animateTo(value,
        //     duration: Duration(microseconds: 1), curve: Curves.linear);
      }
    });
    _historyOffset.remove(_currentdirectory);
    if (mounted) setState(() {});
  }

  initFMPage() async {
    //页面启动的时候的初始化
    if (Platform.isAndroid) {
      await getWorkDirectory();
      appDocDir = await getApplicationDocumentsDirectory(); //初始化App缓存路径
    }
    if (Platform.isMacOS) documentsDir = "./";
    eventBus.on<String>().listen((event) {
      //当触发粘贴，删除等操作需要接收广播来进行刷新
      //这个eventBus的监听是为了检测何时刷新文件列表
      _currentdirectory = event ?? _currentdirectory;
      if (mounted) _getFileNodes(_currentdirectory);
    });
    _currentdirectory = widget.initpath ?? documentsDir;
    _getFileNodes(_currentdirectory);
  }

  repeatAnima() {
    //重复播放动画
    _animationController.reset();
    _animationController.forward();
  }

  _getFileNodes(String path, {Function afterSort}) async {
    _fileNodes = await NiDirectory(path).listAndSort();
    setState(() {});
    getNodeFullArgs();
    if (afterSort != null) afterSort();
    if (widget.pathCallBack != null) widget.pathCallBack(path); //返回当前的路径
  }

  itemOnTap(FileEntity fileNode) {
    if (fileNode.nodeName == "..") {
      //清除所有已选择
      fiMaPageNotifier.removeAllCheck();
      //如果点了两个点的默认始终返上级目录
      String backpath = Directory(_currentdirectory).parent.path; //
      _currentdirectory = backpath;
      _getFileNodes(_currentdirectory, afterSort: () async {
        repeatAnima();
      });
    } else if (!fileNode.isFile) {
      //如果不是文件就进入这个文件夹
      _historyOffset[_currentdirectory] =
          _scrollController.offset; //进入文件夹前把当前文件夹浏览到的Offset保存下来
      if (_currentdirectory == "/")
        _currentdirectory = "$_currentdirectory${fileNode.nodeName}";
      else
        _currentdirectory =
            "$_currentdirectory/${fileNode.nodeName}"; //是否是最顶层文件夹的
      listIsBuilding = true;
      _getFileNodes(_currentdirectory, afterSort: () {
        repeatAnima();
        _scrollController.jumpTo(0);
        Future.delayed(Duration(milliseconds: 1000), () {
          listIsBuilding = false;
        });
      });
    } else if (widget.chooseFile) {
      widget.callback("$_currentdirectory/${fileNode.nodeName}");
    } else {
      // print(FileType.isText(fileNode));
      if (FileEntity.isText(fileNode)) {
        Navigator.of(context).push(MaterialPageRoute(builder: (c) {
          return TextEdit(
            fileNode: fileNode,
          );
        }));
      }

      if (FileEntity.isImg(fileNode)) {
        print("object");
        List<FileEntity> _imagelist = [];
        for (FileEntity _file in _fileNodes) {
          if (FileEntity.isImg(_file)) {
            _imagelist.add(_file);
          }
        }
        PageController controller =
            PageController(initialPage: _imagelist.indexOf(fileNode));
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return Hero(
                tag: fileNode.path,
                child: PageView.builder(
                  controller: controller,
                  itemCount: _imagelist.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.black,
                      child: Image.file(
                        File(_imagelist[index].path),
                        //mode: ExtendedImageMode.Gesture,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      }
    }
  }

  itemOnLongPress(
      String currentFile, FileEntity fileNode, BuildContext context) {
    if (currentFile != "..") {
      int initpage0 = 0;
      int initpage1 = 0;
      if (currentFile.endsWith("_dex")) {
        initpage0 = 1;
      }
      if (currentFile.endsWith("_src")) {
        initpage0 = 1;
        initpage1 = 1;
      }
      showCustomDialog2(
        context: context,
        duration: Duration(milliseconds: 200),
        child: LongPressDialog(
          fileNode: fileNode,
          initpage0: initpage0,
          initpage1: initpage1,
          callback: () async {
            _getFileNodes(
              _currentdirectory,
              afterSort: () {},
            );
          },
        ),
      );
    }
  }

  //这是一个异步方法，来获得文件节点的其他参数
  //
  void getNodeFullArgs() async {
    for (FileEntity fileNode in _fileNodes) {
      //将文件的ls输出详情以空格隔开分成列表
      if (fileNode.nodeName != "..") {
        List<String> infos = fileNode.fullInfo.split(RegExp(r"\s{1,}"));
        fileNode.modified = "${infos[3]}  ${infos[4]}";
        if (fileNode.isFile) {
          fileNode.size = getFileSizeFromStr(infos[2]);
        } else {
          fileNode.itemsNumber = "${infos[1]}项";
        }
        fileNode.mode = infos[0];
        if (mounted) setState(() {});
      }
    }
  }

  Future<bool> onWillPop() async {
    fiMaPageNotifier.removeAllCheck();
    //触发���回
    if (widget.chooseFile) return true; //当在其他��面直接唤起文件管理器的时候返回键直接pop
    if (_currentdirectory == "/") {
      if (!widget.chooseFile) PlatformChannel.Drawer.invokeMethod("Exit");
    }
    String backpath = Directory(_currentdirectory).parent.path;
    _currentdirectory = backpath;
    listIsBuilding = true;
    _getFileNodes(_currentdirectory, afterSort: () {
      repeatAnima();
      _scrollController.jumpTo(0);
      Future.delayed(Duration(milliseconds: 1000), () {
        listIsBuilding = false;
      });
    });
    return false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  FiMaPageNotifier fiMaPageNotifier;
  @override
  Widget build(BuildContext context) {
    fiMaPageNotifier = Provider.of<FiMaPageNotifier>(context, listen: false);
    return Theme(
      data: ThemeData(
        fontFamily: Platform.isLinux ? "NotoSansCJK-Regular" : null,
        textTheme: Theme.of(context).textTheme.copyWith(
              body1: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.black),
            ),
        iconTheme: IconThemeData(color: Color(0xff213349)),
      ),
      child: buildWillPopScope(context),
    );
  }

  WillPopScope buildWillPopScope(BuildContext context) {
    // print(MaterialState.hovered);
    // FlatButton(hoverColor: ,onPressed: null, child: null);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Material(
        textStyle: TextStyle(
          fontFamily: Platform.isLinux ? "NotoSansCJK-Regular" : null,
        ),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        elevation: 8.0,
        child: FadeTransition(
          opacity: _opacityTween,
          child: RefreshIndicator(
            onRefresh: () async {
              if (!listIsBuilding)
                _getFileNodes(_currentdirectory, afterSort: () async {});
            },
            displacement: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(12.0),
              ),
              child: DraggableScrollbar.semicircle(
                controller: _scrollController,
                child: buildListView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      cacheExtent: 400,
      controller: _scrollController,
      itemCount: _fileNodes.length,
      padding: EdgeInsets.only(top: 0.0),
      //不然会有一个距离上面的边距
      itemBuilder: (BuildContext context, int index) {
        // print(widget.fileNode);
        List _tmp = _fileNodes[index].path.split(' -> '); //有的有符号链接
        String currentFile = _tmp.first.split("/").last; //取前面那个就没错
        return FileItem(
          checkCall: (path) {
            // if (fiMaPageNotifier.checkPath.contains(path)) {
            //   fiMaPageNotifier.removeCheck(path);
            // } else {
            //   fiMaPageNotifier.addCheck(path);
            // }
          },
          // isCheck: fiMaPageNotifier.checkPath.contains(_fileNodes[index].path),
          fileNode: _fileNodes[index],
          onTap: () => itemOnTap(_fileNodes[index]),
          apkTool: () {},
          onLongPress: () =>
              itemOnLongPress(currentFile, _fileNodes[index], context),
        );
      },
    );
  }
}

class FileItem extends StatefulWidget {
  final FileEntity fileNode;
  final Function onTap;
  final Function onLongPress;
  final Function apkTool;
  final bool isCheck;
  final Function(String path) checkCall;
  const FileItem({
    Key key,
    this.onTap,
    this.onLongPress,
    this.fileNode,
    this.isCheck = false,
    this.checkCall,
    this.apkTool,
  }) : super(key: key);
  @override
  _FileItemState createState() => _FileItemState();
}

class _FileItemState extends State<FileItem>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController; //动画控制器
  Animation curvedAnimation;
  Animation<double> tweenPadding; //边距动画补间值
  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.bounceOut);
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
  }

  double dx = 0.0;
  double _tmp;
  void _handleDragStart(DragStartDetails details) {
    //控件点击的回调
    _tmp = details.globalPosition.dx;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // print(details.globalPosition);
    // if (dx >= 40.0) {
    //   if (dx != (details.globalPosition.dx - _tmp)) {
    //     Feedback.forLongPress(context);
    //   }
    // } else
    dx = (details.globalPosition.dx - _tmp);
    if (dx >= 40) dx = 40.0;
    if (dx <= 0) dx = 0;
    // print(dx);
    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (dx == 40.0) {
      Feedback.forLongPress(context);
      if (!fiMaPageNotifier.checkNodes.contains(widget.fileNode)) {
        fiMaPageNotifier.addCheck(widget.fileNode);
      }
      setState(() {});
    }
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
    tweenPadding.addListener(() {
      setState(() {
        dx = tweenPadding.value;
      });
    });
    _animationController.reset();
    _animationController.forward().whenComplete(() {});
  }

  FiMaPageNotifier fiMaPageNotifier;
  Widget build(BuildContext context) {
    fiMaPageNotifier = Provider.of<FiMaPageNotifier>(context, listen: false);
    // print(fiMaPageNotifier.checkNodes);
    List _tmp = widget.fileNode.path.split(' -> '); //有的有符号链接
    String currentFile = _tmp.first.split("/").last; //取前面那个就没错
    // /bin -> /system/bin
    Widget _iconData = getWidgetFromExtension(
      widget.fileNode,
      context,
      widget.fileNode.isFile,
    ); //显示的头部件
    return Container(
      height: 54,
      child: Stack(
        children: <Widget>[
          if (fiMaPageNotifier.checkNodes.contains(widget.fileNode))
            Container(
              color: Colors.grey.withOpacity(0.6),
            ),
          InkWell(
            splashColor: Colors.transparent,
            onLongPress: () => widget.onLongPress(),
            onTap: () {
              if (fiMaPageNotifier.checkNodes.isEmpty ||
                  widget.fileNode.nodeName == "..") {
                widget.onTap();
              } else {
                if (fiMaPageNotifier.checkNodes.contains(widget.fileNode)) {
                  fiMaPageNotifier.removeCheck(widget.fileNode);
                } else {
                  fiMaPageNotifier.addCheck(widget.fileNode);
                }
                setState(() {});
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: _handleDragStart,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: Transform(
                transform: Matrix4.identity()..translate(dx),
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Stack(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: _iconData,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 35,
                                child: Text(
                                  currentFile,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              Text(
                                "${widget.fileNode.modified}  ${widget.fileNode.itemsNumber}  ${widget.fileNode.size}  ${widget.fileNode.mode}",
                                maxLines: 1,
                                style: TextStyle(
                                  // fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (widget.fileNode.nodeName.endsWith("_src") &&
                          widget.fileNode.isDirectory)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.build),
                            onPressed: () {
                              showCustomDialog2(
                                isPadding: false,
                                context: context,
                                duration: Duration(milliseconds: 200),
                                child: FullHeightListView(
                                  child:
                                      ApkToolEncode(fileNode: widget.fileNode),
                                ),
                              );
                            },
                          ),
                        ),
                      if (widget.fileNode.nodeName.endsWith("apk"))
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.build),
                            onPressed: () {
                              showCustomDialog2(
                                isPadding: false,
                                context: context,
                                duration: Duration(milliseconds: 200),
                                child: FullHeightListView(
                                  child:
                                      ApkToolDialog(fileNode: widget.fileNode),
                                ),
                              );
                            },
                          ),
                        ),
                      if (_tmp.length == 2)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "->    ",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

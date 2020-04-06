import 'dart:io';
import 'dart:ui';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_toolkit/common/envirpath.dart';
import 'package:flutter_toolkit/main.dart';
import 'package:flutter_toolkit/module/file_manager/dialog/file_copy.dart';
import 'package:flutter_toolkit/module/file_manager/provider/file_manager_notifier.dart';
import 'package:flutter_toolkit/module/file_manager/widgets/file_cliprrect.dart';
import 'package:flutter_toolkit/utils/global_function.dart';
import 'package:flutter_toolkit/utils/platform_channel.dart';
import 'package:flutter_toolkit/utils/platform_util.dart';
import 'package:flutter_toolkit/utils/process.dart';
import 'package:flutter_toolkit/widgets/public_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'colors/file_colors.dart';
import 'fm_drawer.dart';
import 'page/center_drawer.dart';
import 'page/fm_page.dart';
import 'page_choose.dart';
import 'utils/bookmarks.dart';
import 'utils/creat_work_dir.dart';

Directory appDocDir;

class FileManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        debugShowCheckedModeBanner: false,
      title: "文件管理器",
      theme: ThemeData(
        textTheme: TextTheme(
          body1: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
        ),
        brightness: Brightness.light,
        primaryColorBrightness: Brightness.dark,
        backgroundColor: Colors.white,
        accentColor: Color(0xff213349),
        primaryColor: Color(0xff213349),
        // cursorColor: Colors.red,
        // textSelectionColor: Colors.red,
        // textSelectionHandleColor: Colors.red,
      ),
      home: FiMaHome(),
    );
  }
}

class FiMaHome extends StatefulWidget {
  const FiMaHome({
    Key key,
  }) : super(key: key);
  @override
  _FiMaHomeState createState() => _FiMaHomeState();
}

enum FileState {
  checkWindow,
  fileDefault,
}

EventBus eventBus = EventBus();

class _FiMaHomeState extends State<FiMaHome> with TickerProviderStateMixin {
  List<String> _paths = [];
  double _drawerWidth = 0.0;
  PageController _pageController = PageController(); //最下面接收手势的Widget
  PageController _commonController =
      PageController(initialPage: 0); //主页面切换的页面切换控制器
  PageController _titlePageController =
      PageController(initialPage: 0); //头部是一个可以滑动的PageView
  int currentPage = 0; //当前页面
  AnimationController animationController;
  FileState fileState = FileState.fileDefault;
  AnimationController pastIconAnimaController;
  bool pageIsInit = false;
  @override
  void initState() {
    super.initState();
    initAnimation();
    initFMPage();
  }

  //初始化动画
  initAnimation() {
    pastIconAnimaController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
  }

  initFMPage() async {
    await creatWorkDirectory();
    await getWorkDirectory();
    if (Platform.isAndroid)
      appDocDir = await getApplicationDocumentsDirectory();
    _pageController.addListener(() {
      // _scrollController.jumpTo(_pageController.offset);
      _commonController.jumpTo(_pageController.offset);
      // print(_pageController.offset);
      currentPage = _pageController.page.toInt();
      _titlePageController.animateToPage(_pageController.page.round(),
          duration: Duration(milliseconds: 200),
          curve: Curves.linear); //title的文件夹路径动画
      setState(() {});
    });
    getHistoryPaths();
    // print(appDocDir);
  }

  //软件将页面路径的列表以换行符分割保存进了储存
  getHistoryPaths() async {
    String temp;
    try {
      temp = await File("${EnvirPath.filesPath}/FileManager/History_Path")
          .readAsString();
    } catch (e) {
      if (Platform.isAndroid)
        temp = "/storage/emulated/0";
      else
        temp = "$documentsDir";
    }
    _paths = temp.trim().split("\n");
    await Future.delayed(Duration(milliseconds: 400));
    pageIsInit = true; //这个值为真才会启动左右滑动的效果
    setState(() {});
  }

  addNewPage(String path) {
    //添加一个页面
    _paths.add(path);
    setState(() {});
    setStatePathFile();
    changePage(_paths.length - 1);
  }

  Future deletePage(int index) async {
    // _paths.removeAt(index);
    setState(() {});
    setStatePathFile();
  }

  changePage(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 800), curve: Curves.ease);
  }

  setStatePathFile() {
    if (Platform.isAndroid)
      File("${EnvirPath.filesPath}/FileManager/History_Path")
          .writeAsString(_paths.join("\n"));
  }

  @override
  void dispose() {
    _titlePageController.dispose();
    _commonController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  void _onAfterRendering(Duration timeStamp) {
    //页面构建完成后悔拿到context
    if (Platform.isAndroid) {
      _drawerWidth = MediaQuery.of(context).size.width * 3 / 4;
    } else {
      _drawerWidth = 300.0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FMDrawer(
        width: _drawerWidth,
      ),
      backgroundColor: Colors.white,
      body: Builder(
        builder: (BuildContext context) {
          return Stack(
            children: <Widget>[
              if (_paths.isEmpty)
                SpinKitThreeBounce(
                  color: FileColors.fileAppColor,
                  size: 16.0,
                )
              else
                buildStack(context),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 20.0,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _paths.length,
                    itemBuilder: (c, i) {
                      return Container(
                        height: 20,
                        color: Colors.transparent,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: <Widget>[
      //     Padding(
      //       padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      //       child: ScaleTransition(
      //         scale:
      //             _rotated.drive(Tween<double>(begin: 0.0, end: 1.0 / 0.125)),
      //         child: FloatingActionButton(
      //           onPressed: () async {
      //             showCustomDialog2(
      //               child: FullHeightListView(
      //                 child: AddFileNode(
      //                   currentPath: _paths[_titlePageController.page.toInt()],
      //                   isAddFile: false,
      //                 ),
      //               ),
      //             );
      //           },
      //           child: Icon(
      //             Octicons.getIconData("file-directory"),
      //             size: 24.0,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      //       child: ScaleTransition(
      //         scale:
      //             _rotated.drive(Tween<double>(begin: 0.0, end: 1.0 / 0.125)),
      //         child: FloatingActionButton(
      //           onPressed: () async {
      //             showCustomDialog2(
      //               child: FullHeightListView(
      //                 child: AddFileNode(
      //                   currentPath: _paths[_titlePageController.page.toInt()],
      //                   isAddFile: true,
      //                 ),
      //               ),
      //             );
      //           },
      //           child: Icon(
      //             Octicons.getIconData("file"),
      //             size: 24.0,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.all(8.0),
      //       child: FloatingActionButton(
      //         onPressed: () async {
      //           if (animationController.isDismissed) {
      //             await animationController.forward();
      //           } else if (animationController.isCompleted) {
      //             await animationController.reverse();
      //           }
      //           // animationController.reverse();
      //         },
      //         child: RotationTransition(
      //           turns: _rotated,
      //           child: Icon(
      //             Icons.add,
      //             size: 36.0,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Matrix4 matrix4;
  Stack buildStack(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Align(
          alignment: FractionalOffset.center,
          child: buildAppBar(context),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: MediaQueryData.fromWindow(window).padding.top +
                  kToolbarHeight),
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: _commonController,
                itemCount: _paths.length,
                itemBuilder: (BuildContext context, int index) {
                  double scale = 1.0;
                  if (pageIsInit) {
                    if (index - currentPage == 0)
                      scale = 1 - 0.2 * (_pageController.page - currentPage);
                    if (index - currentPage == 1)
                      scale = 0.8 + 0.2 * (_pageController.page - currentPage);
                  }
                  matrix4 = Matrix4.identity()..scale(scale);
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Transform(
                      transform: matrix4,
                      alignment: Alignment.center,
                      child: Hero(
                        tag: "FM$currentPage",
                        child: FileClipRRect(
                          child: FMPage(
                            // key: GlobalKey(),
                            pathCallBack: (String path) async {
                              _paths[index] = path;
                              setState(() {});
                              setStatePathFile();
                            },

                            initpath: _paths[index],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        CenterDrawer(),
      ],
    );
  }

  int popPage = 0;
  PreferredSize buildAppBar(BuildContext context) {
    FiMaPageNotifier fiMaPageNotifier = Provider.of<FiMaPageNotifier>(context);
    if (fiMaPageNotifier.clipboard.isNotEmpty &&
        pastIconAnimaController.isDismissed)
      pastIconAnimaController.forward();
    else if (fiMaPageNotifier.clipboard.isEmpty &&
        pastIconAnimaController.isCompleted) pastIconAnimaController.reverse();
    //Appbar
    return PreferredSize(
      child: AppBar(
        elevation: 0.0,
        titleSpacing: 0,
        title: InkWell(
          onTap: () async {
            await Clipboard.setData(
                ClipboardData(text: _paths[_titlePageController.page.toInt()]));
            Feedback.forTap(context);
            PlatformChannel.Toast.invokeMethod("已复制当前路径");
          },
          child: SizedBox(
            height: 24.0,
            child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: _titlePageController,
              itemCount: _paths.length,
              itemBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _commonController.hasClients
                          ? _paths[index]
                          : _paths[index],
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        backgroundColor: FileColors.fileAppColor,
        leading: Align(
          alignment: Alignment.center,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            onLongPress: () {
              Scaffold.of(pushContext).openDrawer();
            },
            child: SizedBox(
              height: 36.0,
              width: 36.0,
              child: Icon(Icons.menu, size: 24.0),
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  if (fiMaPageNotifier.clipType == ClipType.Copy)
                    showCustomDialog2(
                      context: context,
                      child: FullHeightListView(
                        child: Copy(
                          targetPath: _paths[_titlePageController.page.toInt()],
                          sourcePaths: fiMaPageNotifier.clipboard,
                        ),
                      ),
                    );
                  else {
                    print(_paths[_titlePageController.page.toInt()]);
                    print(fiMaPageNotifier.clipboard);
                    for (String path in fiMaPageNotifier.clipboard) {
                      await CustomProcess.exec(
                          "mv $path ${_paths[_titlePageController.page.toInt()]}\n");
                    }

                    showToast2("粘贴完成");
                    fiMaPageNotifier.clearClipBoard();
                    eventBus.fire("");
                  }
                  // fiMaPageNotifier.clearClipBoard();
                },
                child: SizedBox(
                  height: 36.0,
                  width: 36.0,
                  child: ScaleTransition(
                    scale: pastIconAnimaController,
                    child: Icon(Icons.content_paste, size: 24.0),
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          //   child: ScaleTransition(
          //     scale: pastIconAnimaController,
          //     child: FloatingActionButton(
          //       mini: true,
          //       // materialTapTargetSize: MaterialTapTargetSize.padded,
          //       onPressed: () async {
          //       },
          //       child: Icon(
          //         Icons.content_paste,
          //         size: 18.0,
          //       ),
          //     ),
          //   ),
          // ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 24.0,
              height: 24.0,
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () {
                  popPage = currentPage;
                  showDialog(
                    useRootNavigator: false,
                    context: context,
                    builder: (c) {
                      return Theme(
                        data: ThemeData(
                            textTheme: TextTheme(
                                body1: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .copyWith(fontSize: 10.0))),
                        child: PageChoose(
                          paths: _paths,
                          initIndex: currentPage,
                          changePageCall: changePage,
                          deletePageCall: deletePage,
                          addNewPageCall: () async {
                            Navigator.of(context).pop();
                            addNewPage(documentsDir);
                          },
                        ),
                      );
                    },
                  );
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                        style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: Text("${_paths.length}"),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Builder(
            builder: (BuildContext context) {
              return Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 36.0,
                  width: 36.0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    child: Icon(Icons.more_vert, size: 22.0),
                    onTapDown: (detials) {},
                    onTap: () {
                      Future showButtonMenu() async {
                        final RenderBox button = context.findRenderObject();
                        final RenderBox overlay =
                            Overlay.of(context).context.findRenderObject();
                        final RelativeRect position = RelativeRect.fromRect(
                          Rect.fromPoints(
                            button.localToGlobal(Offset(button.size.width, 0.0),
                                ancestor: overlay),
                            button.localToGlobal(
                                button.size.bottomRight(Offset.zero),
                                ancestor: overlay),
                          ),
                          Offset.zero & overlay.size,
                        );
                        int choose = await showMenu<int>(
                          context: context,
                          elevation: 1,

                          items: <PopupMenuItem<int>>[
                            PopupMenuItem(
                              value: 0,
                              child: Text("添加书签"),
                            ),
                            PopupMenuItem(
                              child: Text("设为首页"),
                            ),
                            PopupMenuItem(
                              child: Text("查看模式"),
                            ),
                            PopupMenuItem(
                              value: 3,
                              child: Text("退出"),
                            ),
                          ],
                          // initialValue: 0,
                          position: position,
                        );
                        print(choose);
                        if (choose == 0) {
                          BookMarks.addMarks(
                              _paths[_titlePageController.page.toInt()]);
                          showToast2("已添加");
                        }
                        if (choose == 3)
                          PlatformChannel.Drawer.invokeMethod("Exit");
                      }

                      showButtonMenu();
                      // Overlay.of(context).insert(weixinOverlayEntry);
                    },
                  ),
                ),
              );
            },
          ),
          SizedBox(
            width: 10.0,
          )
        ],
      ),
      preferredSize: Size.fromHeight(50),
    );
  }
}

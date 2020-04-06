import 'package:flutter/material.dart';
import 'package:flutter_icons/octicons.dart';
import 'package:flutter_toolkit/main.dart';
import 'package:flutter_toolkit/utils/global_function.dart';
import 'package:flutter_toolkit/utils/process.dart';
import 'package:flutter_toolkit/widgets/public_widgets.dart';

import 'colors/file_colors.dart';
import 'file_manager.dart';
import 'utils/bookmarks.dart';

class FMDrawer extends StatefulWidget {
  final double width;

  const FMDrawer({Key key, this.width}) : super(key: key);
  _FMDrawerState createState() => _FMDrawerState();
}

class _FMDrawerState extends State<FMDrawer> {
  List<String> rootInfo = [];
  List<String> sdcardInfo = [];
  List<String> bookMarks = [];
  @override
  void initState() {
    super.initState();
    init();
    initBookMarks();
  }

  init() async {
    String result = await CustomProcess.exec("df");
    List<String> infos = result.split("\n");
    for (String line in infos) {
      if (line.endsWith("/")) {
        rootInfo = line.split(RegExp(r"\s{1,}"));
        print(rootInfo);
        setState(() {});
      }
      if (line.endsWith("/storage/emulated")) {
        sdcardInfo = line.split(RegExp(r"\s{1,}"));
        print(rootInfo);
        setState(() {});
      }
    }
    // print(result);
  }

  initBookMarks() async {
    bookMarks = await BookMarks.getBookMarks();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        elevation: 8.0,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 100,
                color: FileColors.fileAppColor,
              ),
              Material(
                  color: Colors.white,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 100.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 4.0, top: 4.0),
                          child: Text(
                            "本地路径",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            eventBus.fire("/");
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            height: 48.0,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "根目录",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      rootInfo.isNotEmpty
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text("${rootInfo[0]}"),
                                                Text(
                                                    "${getFileSizeFromStr("${int.parse(rootInfo[2]) * 1024}")}/ ${getFileSizeFromStr("${int.parse(rootInfo[1]) * 1024}")}")
                                              ],
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            eventBus.fire(documentsDir);
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            height: 48.0,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "外部储存",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      sdcardInfo.isNotEmpty
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text("${sdcardInfo[0]}"),
                                                Text(
                                                    "${getFileSizeFromStr("${int.parse(sdcardInfo[2]) * 1024}")}/ ${getFileSizeFromStr("${int.parse(sdcardInfo[1]) * 1024}")}")
                                              ],
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.0, top: 4.0),
                          child: Text(
                            "书签",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        bookMarks.isNotEmpty
                            ? SizedBox(
                                height: bookMarks.length * 40.0,
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(0.0),
                                  itemCount: bookMarks.length,
                                  itemBuilder: (c, i) {
                                    return InkWell(
                                      onTap: () {
                                        eventBus.fire(bookMarks[i]);
                                        Navigator.pop(context);
                                      },
                                      onLongPress: () {
                                        showCustomDialog2(
                                          context: context,
                                          child: FullHeightListView(
                                            child: Column(
                                              children: <Widget>[
                                                InkWell(
                                                  onTap: () {
                                                    BookMarks.removeMarks(
                                                        bookMarks[i]);
                                                    Navigator.pop(context);
                                                    initBookMarks();
                                                  },
                                                  child: SizedBox(
                                                    height: 30.0,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Text("删除该书签"),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: MarksItem(
                                        marksPath: bookMarks[i],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                  ))
              // Padding(
              //   padding: EdgeInsets.only(left: 4.0, top: 4.0),
              //   child: Text(
              //     "其他",
              //     style: TextStyle(
              //       color: Colors.grey,
              //       fontSize: 16.0,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(left: 12.0, top: 4.0),
              //   child: Text(
              //     "Img镜像比较功能",
              //     style: TextStyle(
              //       color: Colors.black,
              //       fontSize: 16.0,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarksItem extends StatefulWidget {
  final String marksPath;

  const MarksItem({Key key, this.marksPath}) : super(key: key);
  @override
  _MarksItemState createState() => _MarksItemState();
}

class _MarksItemState extends State<MarksItem>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController; //动画控制器
  Animation curvedAnimation;
  Animation<double> tweenPadding; //边距动画补间值
  double _tmp;

  double dx = 0.0;

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
    if (dx <= -40) dx = -40.0;
    if (dx >= 0) dx = 0;
    // print(dx);
    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (dx == 40.0) {
      Feedback.forLongPress(context);

      setState(() {});
    }
    // tweenPadding = Tween<double>(
    //   begin: dx,
    //   end: 0,
    // ).animate(curvedAnimation);
    // tweenPadding.addListener(() {
    //   setState(() {
    //     dx = tweenPadding.value;
    //   });
    // });
    // _animationController.reset();
    // _animationController.forward().whenComplete(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: <Widget>[
          Transform(
            transform: Matrix4.identity()..translate(dx),
            child: SizedBox(
              height: 40.0,
              width: MediaQuery.of(context).size.width * 3 / 4,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Octicons.getIconData("file-directory"),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.marksPath.split("/").last),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 3 / 4 - 24,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            widget.marksPath,
                            // softWrap: true,
                            maxLines: 2,
                            // overflow: TextOverflow.visible,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          // Transform(
          //   transform: Matrix4.identity()..translate(dx),
          //   child: SizedBox(
          //     height: 40.0,
          //     child: Text(widget.marksPath),
          //   ),
          // ),
        ],
      ),
    );
  }
}

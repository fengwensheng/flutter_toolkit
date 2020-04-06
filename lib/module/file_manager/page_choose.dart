import 'package:flutter/material.dart';
import 'package:flutter_toolkit/utils/global_function.dart';

import 'page/fm_page.dart';
// import 'package:vibration/vibration.dart';


typedef AddNewPageCall = Future Function();
typedef DeletePageCall = Future Function(int index);
typedef ChangePageCall = void Function(int index);

class PageChoose extends StatefulWidget {
  final int initIndex;
  final List<String> paths;
  final AddNewPageCall addNewPageCall;
  final DeletePageCall deletePageCall;
  final ChangePageCall changePageCall;

  const PageChoose(
      {Key key,
      this.paths,
      this.addNewPageCall,
      this.deletePageCall,
      this.changePageCall,
      this.initIndex})
      : super(key: key);
  @override
  _PageChooseState createState() => _PageChooseState();
}

class _PageChooseState extends State<PageChoose> {
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      print(_scrollController.offset / MediaQuery.of(context).size.width);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xf7f7f7),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Center(
            child: ListView.builder(
              cacheExtent: 9999,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 6,
                  right: MediaQuery.of(context).size.width / 6 - 20),
              // physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              // pageSnapping: false,
              controller: ScrollController(
                  initialScrollOffset: widget.initIndex *
                          2 /
                          3 *
                          MediaQuery.of(context).size.width +
                      20 * widget.initIndex),
              itemCount: widget.paths.length,
              itemBuilder: (BuildContext context, int index) {
                // bool isCur = index == popPage;
                // print(popPage);
                return Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: MediaQuery.of(context).size.height / 2,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              AbsorbPointer(
                                child: FMPage(
                                  chooseFile: true,
                                  key: GlobalObjectKey("FMZ$index"),
                                  initpath: widget.paths[index],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                height: MediaQuery.of(context).size.height / 2,
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                  ),
                                  color: Colors.transparent,
                                  child: InkWell(
                                    highlightColor: Color(0x88d9d9d9),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      widget.changePageCall(index);
                                    },
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment(1, -1),
                                child: SizedBox(
                                  width: 36.0,
                                  height: 36.0,
                                  child: Material(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                    ),
                                    color: Colors.transparent,
                                    child: InkWell(
                                      highlightColor: Color(0xffd9d9d9),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      onTapDown: (_) {
                                        // Vibration.vibrate(
                                        //     duration: 40, amplitude: 255);
                                      },
                                      onTap: () {
                                        if (widget.paths.length > 1) {
                                          int tmp = index;
                                          widget.paths.removeAt(tmp);
                                          widget.deletePageCall(tmp);
                                          setState(() {});
                                        } else {
                                          showToast(
                                              context: context,
                                              message: "至少需要一个页面");
                                        }
                                        print(widget.paths);
                                        print(widget.paths);
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        size: 24.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      widget.paths[index],
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
          Align(
            alignment: Alignment(0, 0.8),
            child: SizedBox(
              width: 128.0,
              height: 36.0,
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                color: Color(0xffededed),
                child: InkWell(
                  highlightColor: Color(0xffd9d9d9),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  onTapDown: (_) {
                    // Vibration.vibrate(duration: 40, amplitude: 255);
                  },
                  onTap: () {
                    widget.addNewPageCall();
                  },
                  child: Icon(
                    Icons.add,
                    size: 36.0,
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

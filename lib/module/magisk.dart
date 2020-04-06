import 'package:flutter/material.dart';
import 'package:flutter_toolkit/utils/process.dart';


class Magisk extends StatefulWidget {
  @override
  _MagiskState createState() => _MagiskState();
}

class _MagiskState extends State<Magisk> {
  int _selectIndex;
  List<Widget> _body = [Text(""), Text("")];
  @override
  void initState() {
    _selectIndex = 0;
    init();
    super.initState();
  }

  init() async {
    String str1 = await CustomProcess.exec( "cat /sbin/.magisk/modules/Nightmare/post-fs-data.sh\n");
    String str2 = await CustomProcess.exec("cat /sbin/.magisk/modules/Nightmare/service.sh\n");
    TextEditingController _textcontroller1 = TextEditingController(text: str1);
    TextEditingController _textcontroller2 = TextEditingController(text: str2);
    _body = [
      TextField(
        controller: _textcontroller1,
        keyboardType: TextInputType.text,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          border: InputBorder.none,
          fillColor: Colors.white10,
          filled: true,
          contentPadding: const EdgeInsets.only(left: 4, top: 8),
        ),
        minLines: 20,
        maxLines: 20,
        autofocus: false,
      ),
      TextField(
        controller: _textcontroller2,
        keyboardType: TextInputType.text,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          border: InputBorder.none,
          fillColor: Colors.white10,
          filled: false,
          contentPadding: const EdgeInsets.only(left: 4, top: 8),
        ),
        minLines: 20,
        maxLines: 20,
        autofocus: true,
      ),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColorBrightness: Brightness.dark,
          accentColorBrightness: Brightness.dark,
          backgroundColor: Colors.white,
          accentColor: Color(0xff25816b),
          primaryColor: Color(0xff25816b),
          splashColor: Color(0x2225816b),
        ),
        home: Scaffold(
          appBar: AppBar(
              leading: Align(
                alignment: Alignment.center,
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(25)),
                  height: 36,
                  width: 36,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    child: const Icon(Icons.menu),
                    onTap: () {
                      Scaffold.of(GlobalObjectKey("main").currentContext)
                          .openDrawer();
                    },
                  ),
                ),
              ),
              backgroundColor: Color(0xff25816b),
              elevation: 4.0,
              primary: true,
              title: Text("M工具箱框架编辑器"),
              actions: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25)),
                      height: 36,
                      width: 36,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        child: const Icon(Icons.search),
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
              ]),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                title: Text(
                  'post-fs-data.sh',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                icon: Icon(
                  Icons.code,
                  color: Colors.black54,
                ),
                activeIcon: Icon(
                  Icons.code,
                  color: Colors.black,
                ),
              ),
              BottomNavigationBarItem(
                title: Text(
                  'system.prop',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                icon: Icon(
                  Icons.code,
                  color: Colors.black54,
                ),
                activeIcon: Icon(
                  Icons.code,
                  color: Colors.black,
                ),
              ),
            ],
            iconSize: 20,
            currentIndex: _selectIndex,
            onTap: (index) {
              setState(() {
                _selectIndex = index;
              });
            },
            //backgroundColor: Colors.white,
            //fixedColor: Colors.black,
            type: BottomNavigationBarType.fixed,
          ),
          body: _body[_selectIndex],
        ));
  }
}

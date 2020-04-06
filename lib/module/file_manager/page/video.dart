import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Video extends StatefulWidget {
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  static const JuanZheng = const MethodChannel("VideoCall");
  int texTureId = 0;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async {
        texTureId = await JuanZheng.invokeMethod("s");
        setState(() {});
        print(texTureId);
      }),
      body: Texture(textureId: texTureId),
    );
  }
}

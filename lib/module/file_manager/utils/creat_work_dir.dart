  import 'dart:io';

creatWorkDirectory() async {
    //创建工作文件夹
    await Directory("/data/data/com.nightmare/files/Apktool/Framework")
        .create(recursive: true);
    await Directory("/data/data/com.nightmare/files/FileManager")
        .create(recursive: true);
  }
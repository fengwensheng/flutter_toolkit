import 'dart:math';

//将int的字节长度装换为可读的字符串
String getFileSize(int size) {
  String _human;
  if (size < 1024) {
    _human = "$size字节";
  } else if (size >= 1024 && size < pow(1024, 2)) {
    size = (size / 10.24).round();
    _human = "${size / 100}k";
  } else if (size >= pow(1024, 2) && size < pow(1024, 3)) {
    size = (size / (pow(1024, 2) * 0.01)).round();
    _human = "${size / 100}MB";
  } else if (size >= pow(1024, 3) && size < pow(1024, 4)) {
    size = (size / (pow(1024, 3) * 0.01)).round();
    _human = "${size / 100}GB";
  }
  return _human;
}

String getFileSizeFromStr(String str) {
  int size = int.tryParse(str);
  String _human;
  if (size < 1024) {
    _human = "$size字节";
  } else if (size >= 1024 && size < pow(1024, 2)) {
    size = (size / 10.24).round();
    _human = "${size / 100}k";
  } else if (size >= pow(1024, 2) && size < pow(1024, 3)) {
    size = (size / (pow(1024, 2) * 0.01)).round();
    _human = "${size / 100}MB";
  } else if (size >= pow(1024, 3) && size < pow(1024, 4)) {
    size = (size / (pow(1024, 3) * 0.01)).round();
    _human = "${size / 100}GB";
  }
  return _human;
}

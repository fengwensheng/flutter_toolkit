import 'dart:async';
import 'dart:convert';
import 'dart:io';

abstract class NightmareProcess extends Process {}

typedef ProcessCallBack = void Function(String output);

class CustomProcess {
  final ProcessCallBack callback;
  static Process _process;
  static bool isUseing = false;
  CustomProcess(this.callback);
  static Process get process => _process;
  String exitCode = "";
  static String getlsPath() {
    if (Platform.isAndroid)
      return "/system/bin/ls";
    else
      return "ls";
  }

  static init() async {
    _process = await Process.start('sh', [],
        includeParentEnvironment: true, runInShell: false);
    // _process.stderr.transform(utf8.decoder).listen((d) {
    //   print(d);
    // });
  }

  static Stream<List<int>> processStdout = _process.stdout.asBroadcastStream();
  static Stream<List<int>> processStderr = _process.stderr.asBroadcastStream();
  static Future<String> exec(String script,
      {ProcessCallBack callback,
      bool getStdout = true,
      bool getStderr = false}) async {
    while (_process == null) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    String output = "";
    // _process.stdout.listen()..
    while (isUseing) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    _process.stdin.write(script + "\necho exitCode\n");
    isUseing = true;
    if (getStdout)
      await processStdout.transform(utf8.decoder).every((v) {
        output += v;
        if (callback != null) callback(v);
        // print("$script来自监听的打印$v");
        if (v.contains("exitCode"))
          return false;
        else
          return true;
      });
    if (getStderr) {
      await processStderr.transform(utf8.decoder).every((v) {
        output += v;
        if (callback != null) callback(v);
        print("来自监听的打印错误输出$v");
        return false;
      });
    }
    isUseing = false;
    return output.replaceAll("exitCode", "").trim();
  }
}

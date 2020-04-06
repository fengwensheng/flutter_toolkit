import 'dart:io';

Future<String> getLibPath(String packageName,[String architextture="arm64"]) async {
    ProcessResult result=await Process.run("sh", ["-c","pm path $packageName"]);
    // print("路径萨达深度哈市的====>${result.stdout}");
    // print("${FileSystemEntity.parentOf(result.stdout)}");
    String libPath="${FileSystemEntity.parentOf(result.stdout)}/lib/$architextture";
    libPath=libPath.replaceAll(RegExp(".*:"), "");
    return libPath;
}
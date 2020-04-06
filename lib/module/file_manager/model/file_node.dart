
class FileNode {
  //这个名字可能带有->/x/x的字符
  final String path;
  //是否是文件
  final bool isFile;
  //
  final String fullInfo;
  //文件创建日期

  String accessed = "";
  //文件修改日期
  String modified = "";
  //如果是文件夹才有该属性，表示它包含的项目数
  String itemsNumber = "";
  // 节点的权限信息
  String mode = "";
  // 文件的大小，isFile为true才赋值该属性
  String size = "";
  String uid="";
  String gid="";
  String get nodeName => path.split(" -> ").first.split("/").last;

  bool get isDirectory=>!isFile;
  FileNode(this.path, this.isFile, this.fullInfo);
}

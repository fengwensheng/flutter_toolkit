class Constant {
  /// debug开关，上线需要关闭
  /// App运行在Release环境时，inProduction为true；当App运行在Debug和Profile环境时，inProduction为false
  static const bool inProduction =
      const bool.fromEnvironment('dart.vm.product');
  static const bool isTest = false;
  static const int versionCode = 60; //防止工具箱被反编译更改版本
}

import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef init_dart_print = Void Function(
    Pointer<NativeFunction<Void Function(Pointer<Utf8>)>>);
typedef InitDartPrint = void Function(
    Pointer<NativeFunction<Void Function(Pointer<Utf8>)>>);

typedef dart_print = Int32 Function();
typedef DartPrint = int Function();

typedef init_uint8_t_call_back = Void Function(
    Pointer<NativeFunction<Void Function(Pointer<Uint8>)>>);
typedef InitUint8CallBack = void Function(
    Pointer<NativeFunction<Void Function(Pointer<Uint8>)>>);
void dartPrintFunc(Pointer<Utf8> c) {
  print(Utf8.fromUtf8(c));
}

typedef videoStreamPlay = Int32 Function(Pointer<Utf8>);
typedef VideoStreamPlay = int Function(Pointer<Utf8>);

class Native {
  static void test() {
    // String libPath = "libterm.so";
    // if (Platform.isLinux) {
    //   libPath = FileSystemEntity.parentOf(Platform.resolvedExecutable) +
    //       "/lib/libterm.so";
    // }
    // var dylib = DynamicLibrary.open(libPath);

    // var pointer =
    //     dylib.lookup<NativeFunction<init_dart_print>>('init_dart_print');
    // InitDartPrint initDartPrint = pointer.asFunction<InitDartPrint>();
    // Pointer<NativeFunction<Void Function(Pointer<Utf8>)>> a =
    //     Pointer.fromFunction(dartPrintFunc);
    // initDartPrint(a);
  }

  static init() {
    var dylib = DynamicLibrary.open("libnative-lib.so");
    var pointer =
        dylib.lookup<NativeFunction<init_dart_print>>("init_dart_print");
    InitDartPrint initDartPrint = pointer.asFunction<InitDartPrint>();
    Pointer<NativeFunction<Void Function(Pointer<Utf8>)>> a =
        Pointer.fromFunction(dartPrintFunc);
    initDartPrint(a);

    // var poiner = dylib.lookup<NativeFunction<init_uint8_t_call_back>>(
    //     "init_uint8_t_call_back");
    // InitUint8CallBack initUint8CallBack =
    //     poiner.asFunction<InitUint8CallBack>();
    // Pointer<NativeFunction<Void Function(Pointer<Uint8>)>> b =
    //     Pointer.fromFunction(uint8Call);
    // initUint8CallBack(b);

    var bofang =
        dylib.lookup<NativeFunction<videoStreamPlay>>("videoStreamPlay");
    VideoStreamPlay videoStrmPlay = bofang.asFunction<VideoStreamPlay>();
    videoStrmPlay(Utf8.toUtf8("/sdcard/MToolkit/1.mp4"));
  }
}

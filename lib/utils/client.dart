import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

const int msgByteLen = 2;
const int msgCodeByteLen = 2;
const int minMsgByteLen = msgByteLen + msgCodeByteLen;

class NetworkManager {
  final String host;
  final int port;
  Socket socket;
  static Stream<List<int>> mStream;
  Int8List cacheData = Int8List(0);
  NetworkManager(this.host, this.port);

  Future<void> init() async {
    try {
      socket = await Socket.connect(host, port, timeout: Duration(seconds: 3));
    } catch (e) {
      print("连接socket出现异常，e=${e.toString()}");
    }
    mStream = socket.asBroadcastStream();
    // socket.listen(decodeHandle,
    //     onError: errorHandler, onDone: doneHandler, cancelOnError: false);
  }

  void decodeHandle(newData) {
    // print(newData);
  }
  void sendByte(List<int> list) {
    Uint8List outputAsUint8List = new Uint8List.fromList(list);
    //给服务器发消息
    try {
      socket.add(outputAsUint8List);
      // print("给服务端发送消息，消息号=$msg");
    } catch (e) {
      // print("send捕获异常：msgCode=$msg，e=${e.toString()}");
    }
  }

  void sendMsg(String msg) {
    Uint8List outputAsUint8List = new Uint8List.fromList(msg.codeUnits);
    //给服务器发消息
    try {
      socket.add(outputAsUint8List);
      print("给服务端发送消息，消息号=$msg");
    } catch (e) {
      print("send捕获异常：msgCode=$msg，e=${e.toString()}");
    }
  }

  void errorHandler(error, StackTrace trace) {
    print("捕获socket异常信息：error=$error，trace=${trace.toString()}");
    socket.close();
  }

  void doneHandler() {
    socket.destroy();
    print("socket关闭处理");
  }
}

class SocketManage {
  static String host = 'xxx.xxx.xxx.xxx';
  static int port = 80;
  static Socket mSocket;
  static Stream<List<int>> mStream;

  static initSocket() async {
    await Socket.connect(host, port).then((Socket socket) {
      mSocket = socket;
      mStream = mSocket.asBroadcastStream(); //多次订阅的流 如果直接用socket.listen只能订阅一次
    }).catchError((e) {
      print('connectException:$e');
      initSocket();
    });
  }

  static void addParams(List<int> params) {
    mSocket.add(params);
  }

  static void dispos() {
    mSocket.close();
  }
}

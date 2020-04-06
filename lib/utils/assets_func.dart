import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toolkit/utils/global_function.dart';
import 'package:flutter_toolkit/widgets/custom_dialog.dart';


/* 
 */
downloadDialog(BuildContext context, String url,
    {void fun(int fullByte)}) async {
  Response response;
  Dio dio = Dio();
  try {
    //404
    response = await dio.head(url);
  } on DioError catch (e) {
    print(e.message);
  }
  if (response == null)
    showToast(context: context, message: "没有找到该资源");
  else {
    Response response;
    Dio dio = Dio();
    response = await dio.head(url);
    int _fullByte =
        int.tryParse(response.headers.value("content-length")); //得到服务器文件返回的字节大小
    String _human = getFileSize(_fullByte); //拿到可读的文件大小返回给用户
    showCustomDialog(
        context,
        const Duration(milliseconds: 300),
        30,
        Material(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("  会花费$_human流量是否继续"),
              Container(
                padding: EdgeInsets.only(),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                height: 30,
                width: 30,
                child: InkWell(
                    highlightColor: Colors.grey,
                    splashColor: Colors.black,
                    borderRadius: BorderRadius.circular(25),
                    child: const Icon(Icons.check),
                    onTap: () {
                      fun(_fullByte);
//
                    }),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                decoration: BoxDecoration(
                    //color: Colors.grey,
                    borderRadius: BorderRadius.circular(25)),
                height: 30,
                width: 30,
                child: InkWell(
                  highlightColor: Colors.grey,
                  splashColor: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                  child: const Icon(Icons.close),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          color: Colors.white,
        ),
        true,
        false);
  }
}

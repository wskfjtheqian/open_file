import 'dart:io';
import 'dart:typed_data';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _total = 1;

  int _count = 0;

  File file;

  ByteBuffer _data;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            if (null != file) Image.file(file),
            if (null != _data) Image.memory(_data.asUint8List()),
            InkWell(
              child: Text("$_count/ $_total === ${(_count.toDouble() / _total.toDouble() * 100).toStringAsFixed(2)}% "),
              onTap: () async {
                var aa = await openFile();
                if (aa.isNotEmpty) {
                  // file = new File(aa[0].path);
                  _data = await aa[0].byteBuffer;
                  setState(() {});
                }
                // var tt = DateTime.now();
                // print(DateTime.now().millisecondsSinceEpoch - tt.millisecondsSinceEpoch);
                // var xhr = new html.HttpRequest();
                // xhr.open("post", "http://192.168.2.40:8822/api/update_file1.api");
                // xhr.overrideMimeType("application/octet-stream");
                // xhr.upload.onProgress.listen((event) {
                //   setState(() {
                //     _count = event.loaded;
                //     _total = event.total;
                //   });
                // });
                // tt = DateTime.now();
                // xhr.send(bb.data);
                // print(DateTime.now().millisecondsSinceEpoch - tt.millisecondsSinceEpoch);
                //

                // var _dio = Dio(BaseOptions(baseUrl: "https://192.168.2.40:8822"));
                // if (_dio.httpClientAdapter is DefaultHttpClientAdapter) {
                //   (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
                //     client.badCertificateCallback = (X509Certificate cert, String host, int port) {
                //       return true;
                //     };
                //   };
                // }
                // await _dio.post(
                //   "/api/update_file1.api",
                //   data: aa[0].readStream(),
                //   queryParameters: {"fileName": "fileName.mp4"},
                //   options: Options(headers: {HttpHeaders.contentLengthHeader: aa[0].size}),
                //   onSendProgress: (int count, int total) {
                //     setState(() {
                //       _count = count;
                //       _total = total;
                //     });
                //   },
                // );

                // print(await aa[0].md5(onProgress: (int count, int total) {
                //   setState(() {
                //     _count = count;
                //     _total = total;
                //   });
                // }));
              },
            ),
          ],
        ),
      ),
    );
  }
}

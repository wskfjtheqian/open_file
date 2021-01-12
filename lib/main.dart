import 'dart:io';

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
        body: Center(
          child: InkWell(
            child: Text("$_count/ $_total === ${(_count.toDouble() / _total.toDouble() * 100).toStringAsFixed(2)}% "),
            onTap: () async {
              var aa = await openFile();
              // var tt = DateTime.now();
              var bb = await aa[0];
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
              // Dio(BaseOptions(baseUrl: "http://192.168.2.40:8822", headers: {
              //   HttpHeaders.contentLengthHeader: aa[0].size,
              // })).post("/api/update_file1.api", data: bb.readStream(), onSendProgress: (int count, int total) {
              //   setState(() {
              //     _count = count;
              //     _total = total;
              //   });
              // });
              print(await aa[0].md5(onProgress: (int count, int total) {
                setState(() {
                  _count = count;
                  _total = total;
                });
              }));
            },
          ),
        ),
      ),
    );
  }
}

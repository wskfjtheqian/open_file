import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:open_file/src/open_file_imp.dart';

MethodChannel _channel;
Map<int, StreamController<List<int>>> _streamMap = {};

enum FileType {
  any,
  media,
  image,
  video,
  audio,
  custom,
}

class _ImpFile extends OFile {
  String _uri;

  String _name;

  String _path;

  DateTime _lastModifiedDate;

  int _size;

  _ImpFile({String name, String path, DateTime lastModifiedDate, int size, String uri}) {
    _name = name;
    _path = path;
    _lastModifiedDate = lastModifiedDate;
    _size = size;
    _uri = uri;
  }

  factory _ImpFile.fromMap(dynamic map) {
    if (null == map) return null;
    var temp;
    return _ImpFile(
      name: map['name']?.toString(),
      path: map['path']?.toString(),
      uri: map['uri']?.toString(),
      lastModifiedDate: null == (temp = map['lastModifiedDate']) ? null : (temp is DateTime ? temp : DateTime.tryParse(temp)),
      size: null == (temp = map['size']) ? null : (temp is num ? temp.toInt() : int.tryParse(temp)),
    );
  }

  @override
  Future<ByteBuffer> get byteBuffer {
    Completer completer = Completer<ByteBuffer>.sync();
    List<int> buffer = [];
    readStream().listen((event) {
      buffer.addAll(event);
    }, onDone: () {
      completer.complete(Uint8List.fromList(buffer).buffer);
    }, onError: (e) {
      completer.completeError(e);
    }, cancelOnError: true);
    return completer.future;
  }

  @override
  get data => this;

  @override
  DateTime get lastModifiedDate => _lastModifiedDate;

  @override
  String get name => _name;

  @override
  String get path => _path;

  @override
  Stream<List<int>> readStream([int start, int end]) {
    var stream = StreamController<List<int>>.broadcast();
    var id = DateTime.now().microsecondsSinceEpoch;
    _channel.invokeMethod("read_stream", {
      "uri": _uri,
      "id": id,
      "start": start,
      "end": end,
    }).then((value) {
      _streamMap[id] = stream;
    }, onError: (e) {
      stream.addError(e);
    });
    return stream.stream;
  }

  @override
  int get size => _size;

  @override
  OBlob slice([int start, int end]) {}
}

Future<List<OFile>> OpenFileImp({allowsMultipleSelection = true, String accept = "*"}) async {
  if (null == _channel) {
    _channel = const MethodChannel('com.exgou.openFile');

    await HttpServer.bind("127.0.0.1", 9560).then((value) {
      value.listen((event) {
        var id = event.uri.queryParameters["id"];
        var stream = _streamMap[int.tryParse(id)];
        if (null == id) {
          event.response.statusCode = 404;
          event.response.close();
        } else {
          event.listen((event) {
            stream.add(event);
          }, onDone: () async {
            await stream.close();
            event.response.close();
            _streamMap.remove(id);
          }, onError: (e) {
            stream.addError(e);
          }, cancelOnError: true);
        }
      });
    });
  }

  final String type = describeEnum(FileType.any);
  return await _channel.invokeListMethod(type, {
    'allowMultipleSelection': allowsMultipleSelection,
    'allowedExtensions': [accept],
    'allowCompression': false,
    'withData': false,
  }).then<List<_ImpFile>>((value) {
    return value.map<_ImpFile>((e) => _ImpFile.fromMap(e)).toList();
  });
}

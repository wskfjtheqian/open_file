// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:open_file/src/open_file_android.dart' as android;

MethodChannel channel;
enum FileType {
  any,
  media,
  image,
  video,
  audio,
  custom,
}


class ImpBlob extends OBlob<Stream<List<int>>> {
  Stream<List<int>> _data;

  int _size;

  ImpBlob(this._data, this._size);

  @override
  Future<ByteBuffer> get byteBuffer async {
    return _data.toList().then((value) {
      var ret = <int>[];
      value.forEach((element) {
        ret.addAll(element);
      });
      return Int8List.fromList(ret).buffer;
    });
  }

  @override
  Stream<List<int>> get data => _data;

  @override
  int get size => _size;

  @override
  String get type => "Blob";

  @override
  @override
  OBlob slice([int start, int end]) {
    return null;
  }
}

class _ImpFile extends OFile<io.File> {
  io.File _data;

  _ImpFile(this._data);

  @override
  get data => _data;

  DateTime get lastModifiedDate => data.lastModifiedSync();

  @override
  String get name {
    var index = data.path.replaceAll(r"\", "/").lastIndexOf("/");
    return data.path.substring(index + 1);
  }

  @override
  String get path => data.path;

  @override
  int get size => data.lengthSync();

  @override
  OBlob slice([int start, int end]) {
    return ImpBlob(data.openRead(start, end), end - start);
  }

  @override
  Stream<List<int>> readStream([int start, int end]) {
    return _data.openRead(start, end);
  }

  @override
  Future<ByteBuffer> get byteBuffer async {
    return data.readAsBytes().then((value) => value.buffer);
  }
}




Future<List<OFile>> OpenFileImp({allowsMultipleSelection = true, String accept = "*"}) async {
  if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
    return showOpenPanel().then<List<_ImpFile>>((value) {
      return value.paths.map<_ImpFile>((e) => _ImpFile(io.File(e))).toList();
    });
  } else if (io.Platform.isAndroid) {
    return android.OpenFileImp(allowsMultipleSelection: allowsMultipleSelection, accept: accept);
  } else if (io.Platform.isIOS) {
    return _IosOpenFileImp(allowsMultipleSelection: allowsMultipleSelection,accept: accept);
  }
}

Future<List<OFile>> _IosOpenFileImp({allowsMultipleSelection = true, String accept = "*"}) async {
  if (null == channel) {
    channel = const MethodChannel('com.exgou.openFile');
  }


  final String type = describeEnum(FileType.any);
  return await channel.invokeListMethod(type, {
    'allowMultipleSelection': allowsMultipleSelection,
    'allowedExtensions': [accept],
    'allowCompression': false,
    'withData': false,
  }).then<List<_ImpFile>>((value) {
    return (value??[]).map<_ImpFile>((e) => _ImpFile(File(e))).toList();
  });
}
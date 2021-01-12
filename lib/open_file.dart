// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'src/open_file_imp.dart' if (dart.library.html) 'src/open_file_web.dart';

abstract class OBlob<T> {
  T get data;

  int get size;

  String get type;

  Future<ByteBuffer> get byteBuffer;
}

abstract class OFile<T> extends OBlob<T> {
  @override
  String get type => "File";

  String get name;

  String get path;

  DateTime get lastModifiedDate;

  int get size;

  Stream<List<int>> readStream([int start, int end]);

  @override
  Future<String> md5({bool allHash, void onProgress(int count, int total)}) async {
    var output = new AccumulatorSink<Digest>();
    var input = sha1.startChunkedConversion(output);
    var s = size;
    if (s < 1024 * 1024 * 10 || null == allHash) {
      allHash = false;
    }

    if (allHash) {
      var comp = Completer<String>.sync();
      var c = 0;
      readStream().listen((event) {
        input.add(event);
        onProgress?.call(c += event.length, s);
      }, onDone: () {
        input.close();
        comp.complete(output.events.single.toString());
      }, onError: (e) {
        comp.completeError(e);
      });
      return comp.future;
    } else {
      double width = (s - 1024) / (100 - 1);
      for (int start, i = 0; i < 100; i++) {
        start = (i * width).toInt();
        await readStream(start, start + 1024).toList().then((value) {
          value.forEach((element) {
            input.add(element);
          });
        });
        onProgress?.call(start, s);
      }
      onProgress?.call(s, s);
      input.close();
      return output.events.single.toString();
    }
  }
}

Future<List<OFile>> openFile({allowsMultipleSelection = true, String accept = "*"}) async {
  return OpenFileImp(allowsMultipleSelection: allowsMultipleSelection, accept: accept);
}

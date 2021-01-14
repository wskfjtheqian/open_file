// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js;
import 'dart:typed_data';
import 'package:open_file/open_file.dart';

export 'open_file_imp.dart';
const int _blockSize = 65536;
class OBlobStreamSubscription implements StreamSubscription<List<int>> {
  html.File _data;
  int _start;
  final int _end;
  Function _handleData;
  bool _isCanceled = false;
  bool _scheduled = false;
  int _pauseCount = 1;

  void Function() _handleDone;

  Function _handleError;

  bool _cancelOnError = false;

  OBlobStreamSubscription(this._data, this._start, this._end);

  bool get isPaused => _pauseCount > 0;

  Future<T> asFuture<T>([T futureValue]) {
    return Future.value();
  }

  Future cancel() {
    _isCanceled = true;
    if (_cancelOnError) {
      _handleError?.call("cancel");
    }
  }

  void onData(void handleData(List<int> data)) {
    _handleData = handleData;
  }

  void onDone(void handleDone()) {
    _handleDone = handleDone;
  }

  void onError(Function handleError) {
    _handleError = handleError;
  }

  void pause([Future resumeSignal]) {
    _pauseCount++;
    if (resumeSignal != null) {
      resumeSignal.whenComplete(resume);
    }
  }

  void resume() {
    if (_isCanceled) {
      if (_cancelOnError) {
        _handleError?.call("cancel");
      }
      return;
    }

    _pauseCount--;
    _maybeScheduleData();
  }

  void _maybeScheduleData() {
    if (_scheduled) return;
    if (_pauseCount != 0) return;
    _scheduled = true;

    Future<void> read() async {
      if (0 == _pauseCount && !_isCanceled) {
        var blod = _data.slice(_start, _start + _blockSize > _end ? _end : _start + _blockSize);
        ByteBuffer array = await js.promiseToFuture(js.callMethod(blod, "arrayBuffer", []));
        _handleData?.call(array.asUint8List());
        _start += _blockSize;
        if (_start >= _end) {
          _handleDone?.call();
        } else {
          await read();
        }
      }
    }

    scheduleMicrotask(read);
  }
}

class OBlobStream extends Stream<List<int>> {
  final html.File _data;

  int _start;

  int _end;

  OBlobStream(this._data, this._start, this._end);

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    return OBlobStreamSubscription(_data, _start, _end)
      ..onData(onData)
      ..onError(onError)
      ..onDone(onDone)
      .._cancelOnError = cancelOnError
      ..resume();
  }
}

class _WebBlob extends OBlob<html.Blob> {
  html.Blob _data;

  _WebBlob._(this._data);

  @override
  Future<ByteBuffer> get byteBuffer async {
    ByteBuffer array = await js.promiseToFuture(js.callMethod(_data, "arrayBuffer", []));
    return array;
  }

  @override
  html.Blob get data => _data;

  @override
  int get size => _data.size;

  @override
  String get type => "Blob";
}

class _WebFile extends OFile<html.File> {
  html.File _data;

  _WebFile(this._data);

  @override
  get data => _data;

  DateTime get lastModifiedDate => data.lastModifiedDate;

  @override
  String get name => data.name;

  @override
  String get path => data.relativePath;

  @override
  int get size => data.size;

  @override
  OBlob slice([int start, int end]) {
    return _WebBlob._(data.slice(start, end ?? size));
  }

  @override
  Stream<List<int>> readStream([int start, int end]) {
    return OBlobStream(_data, start ?? 0, end ?? size);
  }

  @override
  Future<ByteBuffer> get byteBuffer async {
    ByteBuffer array = await js.promiseToFuture(js.callMethod(data, "arrayBuffer", []));
    return array;
  }
}

Future<List<OFile>> OpenFileImp({allowsMultipleSelection = true, String accept = "*"}) async {
  final html.FileUploadInputElement input = html.FileUploadInputElement();
  input.accept = accept;
  input.multiple = allowsMultipleSelection;
  input.click();
  await input.onChange.first;
  if (input.files.isEmpty) {
    return [];
  }
  return input.files.map((e) => _WebFile(e)).toList();
}

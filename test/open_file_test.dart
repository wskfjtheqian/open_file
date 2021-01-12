import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_file/open_file.dart';

void main() {
  const MethodChannel channel = MethodChannel('open_file');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {

  });
}

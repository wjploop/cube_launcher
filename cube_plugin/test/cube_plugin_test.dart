import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cube_plugin/cube_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('cube_plugin');

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
    expect(await CubePlugin.platformVersion, '42');
  });
}

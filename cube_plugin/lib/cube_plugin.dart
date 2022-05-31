
import 'dart:async';

import 'package:flutter/services.dart';

class CubePlugin {
  static const MethodChannel _channel = MethodChannel('cube_plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> get isSetLauncherToSelf async{
    return await _channel.invokeMethod("isSetLauncherToSelf");
  }

  static Future<bool> unstall(String packageName) async{
    return await _channel.invokeMethod("uninstall",{
      "packageName": packageName
    });
  }


}

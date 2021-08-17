import 'package:cube_launcher/data/AppInfo.dart';
import 'package:flutter/material.dart';

import 'cube.dart';

class AppData with ChangeNotifier {
  bool hadLoad = false;

  void loaded() {
    hadLoad = true;
    notifyListeners();
  }
}

class FaceColorMap with ChangeNotifier {
  Map<FaceColor, List<AppInfo?>>? appMap;
  Map<FaceColor, Color> colorMap;

  FaceColorMap(this.appMap, this.colorMap);

  void updateApp(
      Map<FaceColor, List<AppInfo?>>? appMap, Map<FaceColor, Color> colorMap) {
    this.appMap = appMap;
    this.colorMap = colorMap;
    notifyListeners();
  }

  void updateColor(
      Map<FaceColor, List<AppInfo?>>? appMap, Map<FaceColor, Color> colorMap) {
    this.appMap = appMap;
    this.colorMap = colorMap;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) {
    if ((other is FaceColorMap)) {
      return appMap == other.appMap;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}

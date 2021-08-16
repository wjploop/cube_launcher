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
  Map<FaceColor, List<AppInfo?>>? map;

  FaceColorMap(this.map);

  void update(Map<FaceColor, List<AppInfo?>>? map) {
    this.map = map;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) {
    if ((other is FaceColorMap)) {
      return map == other.map;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}


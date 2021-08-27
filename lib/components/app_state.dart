import 'package:cube_launcher/data/AppInfo.dart';
import 'package:cube_launcher/data/Wallpaper.dart';
import 'package:flutter/material.dart';

import 'cube.dart';

class AppData with ChangeNotifier {
  bool hadLoad = false;

  List<Wallpaper> wallpapers = built_in_wallpapers;

  Wallpaper currentWallpaper = built_in_wallpapers.first;

  void updateWallpapers(List<Wallpaper> list) {
    this.wallpapers = list;
    notifyListeners();
  }

  void updateCurrentWallpaper(Wallpaper wallpaper) {
    if (currentWallpaper == wallpaper) {
      return;
    }
    currentWallpaper = wallpaper;
    notifyListeners();
  }

  void loaded() {
    hadLoad = true;
    notifyListeners();
  }
}

class FaceMap with ChangeNotifier {
  Map<FaceColor, List<AppInfo?>>? appMap;
  Map<FaceColor, Color> colorMap;

  FaceMap(this.appMap, this.colorMap);

  void updateApp(Map<FaceColor, List<AppInfo?>>? appMap) {
    this.appMap = appMap;
    notifyListeners();
  }

  void updateColor(Map<FaceColor, Color> colorMap) {
    this.colorMap = colorMap;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) {
    if ((other is FaceMap)) {
      return appMap == other.appMap;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}

import 'package:cube_launcher/data/AppInfo.dart';
import 'package:cube_launcher/data/Wallpaper.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

import 'cube.dart';

class AppData with ChangeNotifier {
  bool hadLoad = false;

  List<AppInfo> apps = [];

  Map<FaceColor, List<AppInfo?>> appMap = {
    FaceColor.YELLOW: List.filled(9, null, growable: false),
    FaceColor.GREEN: List.filled(9, null, growable: false),
    FaceColor.WHITE: List.filled(9, null, growable: false),
    FaceColor.BLUE: List.filled(9, null, growable: false),
    FaceColor.RED: List.filled(9, null, growable: false),
    FaceColor.ORANGE: List.filled(9, null, growable: false),
  };

  Map<FaceColor, Color> colorMap = defaultColorMap;

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

  Future loaded() async {
    apps = await getApps();
    print('apps size ${apps.length}');
    autoPutAppOnCube();
    hadLoad = true;
    listenAppChanges();
    notifyListeners();
    return Future.value();
  }

  void listenAppChanges() {
    Stream<ApplicationEvent> stream = DeviceApps.listenToAppsChanges();
    stream.listen((event) async {
      if (event.event == ApplicationEventType.installed) {
        var installedApp = await DeviceApps.getApp(event.packageName, true);
        if (installedApp == null) {
          // 没有Icon
          return;
        }
        var appWithIcon = installedApp as ApplicationWithIcon;
        var newApp = AppInfo(
          appWithIcon,
          appWithIcon.appName,
          appWithIcon.icon,
          appWithIcon.packageName,
        );
        print('install ${event.packageName}');
        apps = apps.toList()..add(newApp);
        notifyListeners();
        print('update apps size ${apps.length}');
      } else if (event.event == ApplicationEventType.uninstalled) {
        apps = apps.toList()
          ..removeWhere((element) => element.packageName == event.packageName);
        var newAppMap = Map.of(appMap);

        newAppMap.forEach((key, value) {
          var removeIndex = value.indexWhere(
              (element) => element?.packageName == event.packageName);
          print('check face $key index = $removeIndex');
          if (removeIndex != -1) {
            print('uninstall ${event.packageName}');
            newAppMap.update(
                key, (value) => value.toList()..[removeIndex] = null);
          }
        });
        appMap = newAppMap;
        notifyListeners();
        print('update apps size ${apps.length}');
      }
    });
  }

  void autoPutAppOnCube() {
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 9; j++) {
        var index = i * 9 + j;
        var app = index < apps.length ? apps[index] : null;
        // print('put $i and $j');
        appMap[FaceColor.values[i]]?[j] = app;
      }
    }
  }

  static Future<List<AppInfo>> getApps() async {
    var value = await DeviceApps.getInstalledApplications(
        includeSystemApps: true,
        includeAppIcons: true,
        onlyAppsWithLaunchIntent: true);
    var res = value.map((e) {
      var appWithIcon = e as ApplicationWithIcon;
      return AppInfo(
        appWithIcon,
        appWithIcon.appName,
        appWithIcon.icon,
        appWithIcon.packageName,
      );
    }).toList(growable: false);

    return Future.value(res);
  }

  void updateApp(Map<FaceColor, List<AppInfo?>> appMap) {
    this.appMap = appMap;
    notifyListeners();
  }

  void updateColor(Map<FaceColor, Color> colorMap) {
    this.colorMap = colorMap;
    notifyListeners();
  }
}

// class FaceMap with ChangeNotifier {
//   Map<FaceColor, List<AppInfo?>>? appMap;
//   Map<FaceColor, Color> colorMap;
//
//   FaceMap(this.appMap, this.colorMap);
//
//   void updateApp(Map<FaceColor, List<AppInfo?>>? appMap) {
//     this.appMap = appMap;
//     notifyListeners();
//   }
//
//   void updateColor(Map<FaceColor, Color> colorMap) {
//     this.colorMap = colorMap;
//     notifyListeners();
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if ((other is FaceMap)) {
//       return appMap == other.appMap;
//     }
//     return false;
//   }
//
//   @override
//   int get hashCode => super.hashCode;
// }

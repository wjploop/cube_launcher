import 'dart:io';

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/data/Wallpaper.dart';
import 'package:cube_launcher/screen/area_top_bottom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class WallpaperPicker extends StatefulWidget {
  const WallpaperPicker({Key? key}) : super(key: key);

  @override
  _WallpaperPickerState createState() => _WallpaperPickerState();
}

class _WallpaperPickerState extends State<WallpaperPicker> {
  @override
  Widget build(BuildContext context) {
    var items = context
        .watch<AppData>()
        .wallpapers
        .map((wallpaper) => GestureDetector(
              onTap: () async {
                if (wallpaper.type == WallpaperType.gallery_entry) {
                  var image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  var addedWallpaper =
                      Wallpaper(WallpaperType.from_outer, image!.path);
                  var appData = context.read<AppData>();
                  appData.updateWallpapers(appData.wallpapers
                    ..toList()
                    ..insert(0, addedWallpaper)
                    // 图库添加的只保留一个
                    ..removeWhere((e) =>
                        e.type == WallpaperType.from_outer &&
                        e != addedWallpaper));
                  appData.updateCurrentWallpaper(appData.wallpapers.first);
                  context.read<MenuState>().toggleChoosingWallpaper();
                } else {
                  context.read<AppData>().updateCurrentWallpaper(wallpaper);
                }
              },
              child: Container(
                  color: wallpaper == context.watch<AppData>().currentWallpaper
                      ? Colors.deepPurple.withOpacity(0.3)
                      : Colors.white60,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: wallpaper.type == WallpaperType.gallery_entry
                      ? Center(
                          child: Icon(
                          Icons.photo,
                          size: 120,
                        ))
                      : wallpaper.type == WallpaperType.from_outer
                          ? Image.file(File(wallpaper.path))
                          : Image.asset(wallpaper.path)),
            ))
        .toList();
    return ListView(
      scrollDirection: Axis.horizontal,
      children: items,
    );
  }
}

import 'package:cube_launcher/components/app_state.dart';
import 'package:flutter/material.dart';
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
              onTap: () {
                context.read<AppData>().updateCurrentWallpaper(wallpaper);
              },
              child: Container(
                  color: wallpaper == context.watch<AppData>().currentWallpaper
                      ? Colors.deepPurple.withOpacity(0.3)
                      : Colors.white60,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Image.asset(wallpaper.path)),
            ))
        .toList();
    return ListView(
      scrollDirection: Axis.horizontal,
      children: items,
    );
  }
}

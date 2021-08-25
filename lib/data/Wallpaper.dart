class Wallpaper {
  final WallpaperType type;
  String path;

  Wallpaper(this.type, this.path);
}

enum WallpaperType { built_in, from_outer }

var built_in_wallpapers = List<int>.generate(4, (index) => index + 1)
    .map((e) => "assets/images/wallpaper_0$e.jpg")
    .map((e) => Wallpaper(WallpaperType.built_in, e))
    .toList();

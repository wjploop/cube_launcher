import 'dart:io';
import 'dart:math';

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/components/color_picker.dart';
import 'package:cube_launcher/components/cube.dart';
import 'package:cube_launcher/components/cube_component.dart';
import 'package:cube_launcher/components/wallpaper_picker.dart';
import 'package:cube_launcher/data/Wallpaper.dart';
import 'package:cube_launcher/screen/area_bottom_apps_gallery.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const menuHeight = 46.0;

class AreaTopBottom extends StatefulWidget {
  const AreaTopBottom({Key? key}) : super(key: key);

  @override
  _AreaTopBottomState createState() => _AreaTopBottomState();
}

class _AreaTopBottomState extends State<AreaTopBottom> {
  late Cube cube;

  double topOffset = 0;

  bool isPreView = false;

  bool loadingApp = true;

  // 只有第一次加载回踩
  bool firstLayout = true;

  @override
  Widget build(BuildContext context) {
    return
        // screenSize == null?
        LayoutBuilder(builder: (context, constraints) {
      var screenSize = Size(constraints.maxWidth, constraints.maxHeight);

      screenSize = Size(screenSize.width,
          screenSize.height - MediaQuery.of(context).padding.top);

      return content(screenSize);
    });
    // content(screenSize!);
  }

  Widget content(Size screenSize) {
    var topAreaWidth = min(screenSize.width, screenSize.height);
    var topAreaHeight = screenSize.height - menuHeight;

    print('screen size $screenSize');

    var cubeSize = topAreaWidth / 6;

    cube = Cube(pieceSize: cubeSize);

    EventBus eventBus = EventBus();

    double cubeTop(MenuPosition menuPosition) {
      if (menuPosition == MenuPosition.top) {
        return -topAreaHeight;
      } else if (menuPosition == MenuPosition.middle) {
        return -(topAreaHeight - topAreaWidth) / 2;
      } else if (menuPosition == MenuPosition.bottom) {
        return (screenSize.height - menuHeight - topAreaHeight) / 2;
      } else {
        throw "No support menu position $menuPosition";
      }
    }

    double galleryTop(MenuPosition menuPosition) {
      if (menuPosition == MenuPosition.top) {
        return 0;
      } else if (menuPosition == MenuPosition.middle) {
        return screenSize.height - topAreaWidth - menuHeight;
      }
      if (menuPosition == MenuPosition.bottom) {
        return screenSize.height - menuHeight;
      } else {
        throw "No support menu position $menuPosition";
      }
    }

    double faceColorPickerTop(bool editingFaceColor) {
      if (editingFaceColor) {
        return screenSize.height - topAreaWidth;
      } else {
        return screenSize.height;
      }
    }

    double wallpaperPickerTop(bool choosingWallpaper) {
      if (choosingWallpaper) {
        return screenSize.height / 3 * 2 - menuHeight;
      } else {
        return screenSize.height;
      }
    }

    return GestureDetector(
      onDoubleTap: () {},
      child: Consumer<AppData>(
        builder: (context, appdata, child) {
          var wallpaper = appdata.currentWallpaper;
          return Stack(
            fit: StackFit.expand,
            children: [
              wallpaper.type == WallpaperType.from_outer
                  ? Image.file(
                      File(wallpaper.path),
                      fit: BoxFit.cover,
                    )
                  : Image.asset(wallpaper.path, fit: BoxFit.cover),
              Column(
                children: [
                  AnimatedContainer(
                      color: Theme.of(context).primaryColor.withOpacity(
                          context.watch<MenuState>().position ==
                                  MenuPosition.top
                              ? 1
                              : 0),
                      height: MediaQuery.of(context).padding.top,
                      duration: Duration(milliseconds: 500)),
                  Expanded(
                    child: Container(child: Builder(
                      builder: (context) {
                        var menuState = context.watch<MenuState>();
                        return Stack(
                          children: [
                            AnimatedPositioned(
                                duration: Duration(milliseconds: 500),
                                top: cubeTop(menuState.position),
                                child: Container(
                                    constraints: BoxConstraints.tight(
                                        Size(screenSize.width, topAreaHeight)),
                                    height: topAreaHeight,
                                    child: PlayCubeWidget(
                                      cube: cube,
                                      touchable: true,
                                    ))),
                            AnimatedPositioned(
                                top: wallpaperPickerTop(
                                    menuState.pickingWallpaper),
                                child: SizedBox.fromSize(
                                  size: Size(
                                      screenSize.width, screenSize.height / 3),
                                  child: WallpaperPicker(),
                                ),
                                duration: Duration(milliseconds: 500)),
                            AnimatedPositioned(
                                top: galleryTop(menuState.position),
                                duration: Duration(milliseconds: 500),
                                child: SizedBox.fromSize(
                                  size: screenSize,
                                  child: AppGalley(),
                                )),
                            AnimatedPositioned(
                                top: faceColorPickerTop(
                                    menuState.editingFaceColor),
                                child: SizedBox.fromSize(
                                  size: Size(
                                      screenSize.width,
                                      screenSize.height -
                                          topAreaWidth +
                                          menuHeight),
                                  child: FaceColorPicker(),
                                ),
                                duration: Duration(milliseconds: 500)),
                          ],
                        );
                      },
                    )),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class MenuState with ChangeNotifier {
  MenuPosition position;
  bool editingApp;

  bool editting() => editingApp | editingFaceColor;

  // 默认翻转到 front
  FaceColor editFace = FaceColor.RED;

  // 是否正在编辑魔方页面
  bool editingFaceColor = false;

  bool pickingWallpaper = false;

  bool playing = false;

  MenuState(this.position, this.editingApp);

  void update(MenuPosition position, bool edit) async {
    this.editingApp = edit;
    this.position = position;
    editingFaceColor = false;
    notifyListeners();
  }

  void updateEditFace(FaceColor faceColor) {
    this.editFace = faceColor;
    notifyListeners();
  }

  void toggleEditFaceColor() {
    this.editingFaceColor = !editingFaceColor;
    notifyListeners();
  }

  void toggleChoosingWallpaper() {
    this.pickingWallpaper = !pickingWallpaper;
    notifyListeners();
  }

  void updatePlaying(bool playing) {
    this.playing = playing;
    notifyListeners();
  }

  List<MenuAction> actions() {
    if (pickingWallpaper) {
      return [MenuAction.action_choose_wallpaper];
    }
    if (editingFaceColor) {
      return [MenuAction.action_choose_color];
    }
    if (editingApp) {
      return [MenuAction.action_editing_cube];
    }
    List<MenuAction> actions = [];
    switch (position) {
      case MenuPosition.top:
        actions.addAll({MenuAction.action_arrow_down});
        break;
      case MenuPosition.middle:
        actions.addAll({
          MenuAction.action_editing_cube,
          MenuAction.action_choose_color,
          MenuAction.action_arrow_up,
          MenuAction.action_arrow_down
        });
        break;
      case MenuPosition.bottom:
        actions.addAll({
          MenuAction.action_start_rotating,
          MenuAction.action_choose_wallpaper,
          MenuAction.action_arrow_up
        });
        break;
      default:
        break;
    }
    return actions;
  }
}

enum MenuAction {
  action_arrow_up,
  action_arrow_down,
  action_editing_cube,
  action_choose_color,
  action_choose_wallpaper,
  action_start_rotating,
}

enum MenuPosition {
  top,
  middle,
  bottom,
}

MenuPosition next(MenuPosition cur) {
  return MenuPosition.values[(cur.index + 1) % MenuPosition.values.length];
}

MenuPosition prev(MenuPosition cur) {
  return MenuPosition.values[(cur.index - 1) % MenuPosition.values.length];
}

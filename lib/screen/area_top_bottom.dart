import 'dart:math';

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/components/cube.dart';
import 'package:cube_launcher/components/cube_component.dart';
import 'package:cube_launcher/screen/area_bottom_apps_gallery.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const menuHeight = 46;

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        var topAreaHeight = min(screenSize.width, screenSize.height);

        print('screen size $screenSize');

        var cubeSize = topAreaHeight / 6;

        cube = Cube(pieceSize: cubeSize);

        EventBus eventBus = EventBus();

        double cubeTop(MenuPosition menuPosition) {
          if (menuPosition == MenuPosition.top) {
            return -topAreaHeight;
          } else if (menuPosition == MenuPosition.middle) {
            return 0;
          }
          if (menuPosition == MenuPosition.bottom) {
            return (screenSize.height - menuHeight - topAreaHeight) / 2;
          } else {
            throw "No support menu position $menuPosition";
          }
        }

        double galleryTop(MenuPosition menuPosition) {
          if (menuPosition == MenuPosition.top) {
            return 0;
          } else if (menuPosition == MenuPosition.middle) {
            return screenSize.height - topAreaHeight;
          }
          if (menuPosition == MenuPosition.bottom) {
            return screenSize.height - menuHeight;
          } else {
            throw "No support menu position $menuPosition";
          }
        }

        return GestureDetector(
          onDoubleTap: () {},
          child: Consumer<AppData>(
            builder: (context, appdata, child) => Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/cool_bg_1.jpg"),
              )),
              child: ChangeNotifierProvider(
                create: (context) => MenuState(MenuPosition.top),
                builder: (context, child) {
                  var menuPosition = context.watch<MenuState>().position;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                          duration: Duration(milliseconds: 500),
                          top: cubeTop(menuPosition),
                          child: Container(
                              constraints: BoxConstraints.tight(
                                  Size(screenSize.width, topAreaHeight)),
                              height: topAreaHeight,
                              child: PlayCubeWidget(
                                cube: cube,
                                touchable: true,
                                eventBus: eventBus,
                              ))),
                      AnimatedPositioned(
                          top: galleryTop(menuPosition),
                          duration: Duration(milliseconds: 500),
                          child: SizedBox.fromSize(
                            size: screenSize,
                            child: AppGalley(),
                          ))
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class MenuState with ChangeNotifier {
  late MenuPosition position;

  MenuState(MenuPosition position) {
    this.position = position;
  }

  void update(MenuPosition position) {
    this.position = position;
    notifyListeners();
  }
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
  return MenuPosition.values[(cur.index + 1) % MenuPosition.values.length];
}

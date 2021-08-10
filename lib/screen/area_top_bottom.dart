import 'dart:math';

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/components/cube.dart';
import 'package:cube_launcher/components/cube_component.dart';
import 'package:cube_launcher/screen/area_bottom_apps_gallery.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

        return GestureDetector(
          onDoubleTap: () {},
          child: Consumer<AppData>(
            builder: (context, appdata, child) => Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/cool_bg_1.jpg"),
              )),
              child: Stack(
                children: [
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 3000),
                      top: appdata.hadLoad ? 0 : -topAreaHeight,
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
                      top: appdata.hadLoad ? topAreaHeight : 0,
                      duration: Duration(milliseconds: 3000),
                      child: SizedBox.fromSize(
                        size: screenSize,
                        child: AppGalley(),
                      ))
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:ui';

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/data/AppInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cube.dart';

class LauncherIconWidget extends StatelessWidget {
  final FaceColor faceColor;
  final int positionInAFace;
  final bool editing;

  const LauncherIconWidget(
      {Key? key,
      required this.faceColor,
      required this.positionInAFace,
      required this.editing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (faceColor == FaceColor.BLACK) {
      return Container(
        color: Colors.black,
      );
    }
    return Consumer<FaceColorMap>(builder: (context, map, child) {
      var currentFace = map.map?[faceColor]!;

      var app = currentFace![positionInAFace];

      Widget AppIcon(
        AppInfo app,
      ) {
        return ClipOval(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Image.memory(
              app.icon,
              color: colorMap[faceColor],
              colorBlendMode: BlendMode.lighten,
            ),
          ),
        );
      }

      var appIcon = app == null
          ? Container(
              child: DragTarget<AppInfo>(
                onWillAccept: (data) {
                  return true;
                },
                builder: (context, candidateData, rejectedData) {
                  if (candidateData.isEmpty) {
                    return Container();
                  }
                  return AppIcon(candidateData.first!);
                },
                onAccept: (data) {
                  currentFace[positionInAFace] = data;
                  map.map?[faceColor] = currentFace;
                  context.read<FaceColorMap>().update(map.map);
                },
              ),
            )
          : Stack(
              children: [
                AppIcon(app),
                Container(
                  constraints: BoxConstraints.expand(),
                  alignment: Alignment.topRight,
                  child: LayoutBuilder(builder: (context, constraints) {
                    var closeIconSize = constraints.maxWidth / 3;
                    return Visibility(
                      visible: editing,
                      child: GestureDetector(
                        onTap: () {
                          // 将该app移除
                          currentFace[positionInAFace] = null;
                          map.map?[faceColor] = currentFace;
                          context.read<FaceColorMap>().update(map.map);
                        },
                        child: Container(
                          margin: EdgeInsets.all(4),
                          width: closeIconSize,
                          height: closeIconSize,
                          child: ClipOval(
                              child: Container(
                                  color: Colors.white60,
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: closeIconSize - 8,
                                  ))),
                        ),
                      ),
                    );
                  }),
                )
              ],
            );

      var icon = Container(
        decoration: BoxDecoration(
            color: colorMap[faceColor],
            border: Border.all(color: Colors.black, width: 1)),
        child: appIcon,
      );

      return GestureDetector(
        onTap: () {
          app?.rawApp.openApp();
        },
        onLongPress: () {
          app?.rawApp.openSettingsScreen();
        },
        child: Container(
          child: icon,
        ),
      );
    });
  }
}

var colorMap = {
  FaceColor.YELLOW: Colors.yellow,
  FaceColor.GREEN: Colors.green,
  FaceColor.WHITE: Colors.white,
  FaceColor.BLUE: Colors.blue,
  FaceColor.RED: Colors.redAccent,
  FaceColor.ORANGE: Colors.orange,
  FaceColor.BLACK: Colors.black,
};

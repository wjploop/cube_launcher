import 'dart:ui';

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/data/AppInfo.dart';
import 'package:cube_launcher/screen/area_top_bottom.dart';
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
    return Consumer<FaceMap>(builder: (context, map, child) {
      var currentFace = map.appMap?[faceColor]!;

      var app = currentFace![positionInAFace];

      Widget AppIcon(
        AppInfo app,
      ) {
        return ClipOval(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Image.memory(
              app.icon,
              color: context.watch<FaceMap>().colorMap[faceColor],
              colorBlendMode: BlendMode.lighten,
            ),
          ),
        );
      }

      var appWidget = app == null
          ? Container()
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
                          map.appMap?[faceColor] = currentFace;
                          context.read<FaceMap>().updateApp(
                                map.appMap,
                              );
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

      var dragTarget = Container(
        child: DragTarget<AppInfo>(
          onWillAccept: (data) {
            return true;
          },
          builder: (context, candidateData, rejectedData) {
            if (candidateData.isEmpty) {
              return appWidget;
            }
            return AppIcon(candidateData.first!);
          },
          onAccept: (data) {
            currentFace[positionInAFace] = data;
            map.appMap?[faceColor] = currentFace;
            context.read<FaceMap>().updateApp(
                  map.appMap,
                );
          },
        ),
      );

      var icon = Container(
        decoration: BoxDecoration(
            color: context.watch<FaceMap>().colorMap[faceColor],
            border: Border.all(color: Colors.black, width: 1)),
        child: dragTarget,
      );

      return GestureDetector(
        onTap: () {
          if (context.read<MenuState>().editting()) {
            return;
          }
          app?.rawApp.openApp();
        },
        child: Container(
          child: icon,
        ),
      );
    });
  }
}

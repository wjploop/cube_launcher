import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'cube.dart';
import 'launcher_icon_widget.dart';


class CubeWidget extends StatelessWidget {
  const CubeWidget({Key? key, required this.cube}) : super(key: key);
  final Cube cube;

  @override
  Widget build(BuildContext context) {

    var widgets = cube.orderedPaintSurfaces.asMap().entries
        .map((e) {
          int index = e.value.positionInSameColor;
          PieceSurface ps = e.value;
      return LayoutId(
        id: ps.piece.toString() + ps.face.toString(),
        child: Transform(
          transform: cube.cameraTransform.multiplied(ps.piece.transform)
            ..multiply(ps.canvasTransform),
          alignment: Alignment.center,
          child: LauncherIconWidget(faceColor: ps.color, positionInAFace:index),
        ),
      );
    }).toList();

    return CustomMultiChildLayout(
        delegate: CubeLayoutDelegate(cube), children: widgets);
  }
}

class CubeLayoutDelegate extends MultiChildLayoutDelegate {
  final Cube cube;

  CubeLayoutDelegate(this.cube);

  @override
  void performLayout(ui.Size size) {
    print('cube size $size');
    var center = size.center(Offset.zero);
    cube.orderedPaintSurfaces.forEach((PieceSurface ps) {
      var id = ps.piece.toString() + ps.face.toString();
      if (hasChild(id)) {
        Size childSize = layoutChild(
            id, BoxConstraints.tight(Size(cube.pieceSize, cube.pieceSize)));
        positionChild(
            id, center.translate(-childSize.width / 2, -childSize.height / 2));
      }
    });
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

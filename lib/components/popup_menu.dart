import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LayoutPopupMenu extends SingleChildLayoutDelegate {
  final Rect attachedRect;

  LayoutPopupMenu(this.attachedRect);

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    return true;
  }

  static double dx = 0;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    print('parent size $size');
    print('attached rect $attachedRect');
    print('left ${attachedRect.left}');
    var offset = Offset(
        attachedRect.left + (attachedRect.width - childSize.width) / 2,
        attachedRect.top - childSize.height);

    print('paint dialog offset $offset');

    dx = 0;
    // todo 边距值10改用window的padding
    if (offset.dx < 10) {
      dx = 10 - offset.dx;
    }
    if (offset.dx + childSize.width > size.width - 10) {
      dx = size.width - 10 - (offset.dx + childSize.width);
    }

    return offset.translate(dx, 0);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.tightFor();
  }
}

class ArrowDialogPainter extends CustomPainter {
  final Rect attachedRect;
  final double arrowHeight;

  ArrowDialogPainter(this.attachedRect, {this.arrowHeight = 20});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromLTRBR(
            0, 0, size.width, size.height - arrowHeight, Radius.circular(10)),
        Paint()
          ..color = Colors.white
          ..strokeJoin = StrokeJoin.round);

    var path = Path()
      ..moveTo(size.width / 2 - LayoutPopupMenu.dx, size.height)
      ..relativeLineTo(arrowHeight / 2, -(arrowHeight * sin(pi / 3) + 3))
      ..relativeLineTo(-(arrowHeight * sin(pi / 3) + 2), 0)
      ..close();

    var paint = Paint()..color = Colors.white;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cube_launcher/data/event.dart';
import 'package:cube_launcher/data/matrix3_process.dart';
import 'package:cube_launcher/screen/area_top_bottom.dart';
import 'package:event_bus/event_bus.dart' show EventBus;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import 'cube.dart';
import 'cube_piece_widget.dart';

const _90Degree = math.pi / 2;

class PlayCubeWidget extends StatefulWidget {
  final Cube cube;
  final bool touchable;
  final EventBus eventBus;

  PlayCubeWidget(
      {required this.cube, this.touchable = true, required this.eventBus});

  double cubeAreaHeight() => cube.pieceSize * 6;

  @override
  _PlayCubeWidgetState createState() => _PlayCubeWidgetState();
}

class _PlayCubeWidgetState extends State<PlayCubeWidget>
    with PlayCubeMixin, TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    context.read<EventBus>().on<RotateToEditEvent>().listen((e) {
      setState(() {
        widget.cube.rotateToConfig();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuState>(
      builder: (context, menuState, child) => GestureDetector(
        onPanStart: (DragStartDetails details) {
          if (!widget.touchable) {
            return;
          }
          onPanStart(details);
        },
        onPanEnd: (DragEndDetails details) async {
          if (!widget.touchable) {
            return;
          }
          await onPanEnd(details);
          setState(() {});
        },
        onPanUpdate: (DragUpdateDetails details) {
          if (!widget.touchable) {
            return;
          }
          // 移动中
          setState(() {
            onPanUpdate(details);
          });
        },
        onDoubleTap: () {
          setState(() {
            widget.cube.rotateToConfig();
            menuState.update(menuState.position, !menuState.editingApp);
          });
        },
        child: Container(
          color: Colors.transparent,
          child: CubeWidget(
            editing: context.watch<MenuState>().editingApp,
            cube: getCube(),
          ),
        ),
      ),
    );
  }

  @override
  Cube getCube() {
    return widget.cube;
  }

  @override
  TickerProvider getVSync() {
    return this;
  }
}

mixin PlayCubeMixin<T extends StatefulWidget> on State<T> {
  Cube getCube();

  TickerProvider getVSync();

  PieceSurface? selectedSurface; // touch selected surface
  List<CubePiece>? rotatingPieces; // all rotating pieces

  late AnimationController faceController;

  Vector3? currentAxis;
  late double animationLastAngle;
  double animationAngleRatio = 1;
  double totalAngle = 0.0; // total angle of animation

  bool _inAnimation = false;

  //编辑状态的旋转
  List<double> editingStartXY = [0, 0];
  bool editStartScroll = false;
  final SCROLL_DISTANCE = 4;
  var scrollAxisType = -1;
  var scrollAxis = [Vector3(1, 0, 0), Vector3(0, 1, 0)];
  var scrollAngle = 0.0;
  late AnimationController fullFaceController;
  var scrollLastValue = 0.0;
  var scrollTargetValue = 0.0;
  double scrollTargetSign = 1;

  @override
  void dispose() {
    faceController.dispose();
    fullFaceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    fullFaceController = AnimationController(
      vsync: getVSync(),
      duration: Duration(milliseconds: 500),
      animationBehavior: AnimationBehavior.preserve,
    );

    fullFaceController.addListener(() {
      setState(() {
        var diff = fullFaceController.value - scrollLastValue;
        print('value faceController.value ${fullFaceController.value}');
        getCube().cameraMovedOnRelative(
            scrollAxis[scrollAxisType], scrollTargetSign * diff);
        print('diff = $diff');

        scrollLastValue = fullFaceController.value;
      });
    });
    fullFaceController.addStatusListener((status) {
      print('full anim status $status');
      if (status == AnimationStatus.completed) {
        // 当前显示的是哪个面？
        // 一个面会有4种状态？6个面，这样会有24种状态
        //
        setState(() {
          var rotation = getCube().cameraTransform.getRotation();
          // print(standardMatrix3Format(rotation));
          var str = standardMatrix3(rotation);
          FaceColor endColor = FaceColor.BLACK;
          standardRotation.forEach((key, value) {
            if (value.contains(str.replaceAll("\n", ""))) {
              endColor = key;
            }
          });
          // assert(endColor != FaceColor.BLACK);
          print('end color $endColor');
          context.read<MenuState>().updateEditFace(endColor);
        });
      }
    });

    faceController = AnimationController(
      vsync: getVSync(),
    );

    faceController.addListener(() {
      setState(() {
        double angle = faceController.value - animationLastAngle;
        angle = angle * animationAngleRatio;
        getCube().rotatePieces(
          currentAxis!,
          rotatingPieces!,
          angle,
        );
        totalAngle += angle;
        animationLastAngle = faceController.value;
      });
    });
  }

  Future<void> restoreFace() async {
    if (totalAngle == 0) {
      return;
    }
    int step = getMoveStep(totalAngle, _90Degree);
    double angle = getMoveRestoreAngle(totalAngle, _90Degree);

    final upperBound = faceController.upperBound;
    animationAngleRatio = angle / upperBound;
    animationLastAngle = 0;
    faceController.value = 0;

    _inAnimation = true;
    await faceController.animateTo(upperBound,
        duration: const Duration(milliseconds: 100));
    _inAnimation = false;

    getCube().rotatePiecePositions(currentAxis!, step, rotatingPieces!);
  }

  Future<void> restoreCamera() async {}

  void onPanStart(DragStartDetails details) {
    if (_inAnimation) {
      return;
    }
    if (context.read<MenuState>().editting()) {
      editingStartXY.fillRange(0, 2, 0);
      scrollAngle = 0.0;
      return;
    }
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
    Size boxSize = renderBox.size;
    double tx = localOffset.dx - boxSize.width / 2;
    double ty = localOffset.dy - boxSize.height / 2;

    selectedSurface = null;
    for (var p in getCube().orderedTouchableSurfaces()) {
      if (p.containsPoint(tx, ty)) {
        selectedSurface = p;
        break;
      }
    }
  }

  Future<void> onPanEnd(DragEndDetails details) async {
    if (_inAnimation) {
      return;
    }
    if (editStartScroll) {
      editStartScroll = false;
      // 自然滚动到标准角度
      var currentAngle = scrollAngle % (math.pi / 2.0);
      var remainAngel;
      if (currentAngle > 0) {
        remainAngel = currentAngle > (math.pi / 4.0)
            ? math.pi / 2.0 - currentAngle
            : -currentAngle;
      } else {
        remainAngel = currentAngle.abs() > (math.pi / 4.0)
            ? -(math.pi / 2.0 - currentAngle.abs())
            : currentAngle;
      }
      scrollAngle += remainAngel;
      print('remain angel $remainAngel');

      scrollLastValue = 0;
      _inAnimation = true;
      scrollTargetSign = remainAngel > 0 ? 1 : -1;
      // 注意target正值，否则current.value > target 则会判断不必执行动画了
      //
      await fullFaceController.animateTo(scrollTargetSign * remainAngel,
          curve: Curves.ease);
      _inAnimation = false;
    }
    // move is done
    if (totalAngle != 0) {
      if (selectedSurface != null) {
        await restoreFace();
      } else {
        await restoreCamera();
      }
    }
    resetAnimationValues();
  }

  void resetAnimationValues() {
    selectedSurface = null;
    currentAxis = null;
    rotatingPieces = null;
    totalAngle = 0.0;
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_inAnimation) {
      return;
    }
    // moving
    final dx = details.delta.dx;
    final dy = details.delta.dy;

    if (dx == 0 && dy == 0) {
      return;
    }
    if (context.read<MenuState>().editting()) {
      // 只允许左右移动，上下移动
      editingStartXY[0] += dx;
      editingStartXY[1] += dy;
      var needStartDelta = false;

      if (!editStartScroll) {
        // 检测应该绕哪个轴滚动
        if (editingStartXY[0].abs() > SCROLL_DISTANCE) {
          // 绕Y轴
          editStartScroll = true;
          scrollAxisType = 1;
        } else if (editingStartXY[1].abs() > SCROLL_DISTANCE) {
          // 绕X轴
          scrollAxisType = 0;
          editStartScroll = true;
        }
        needStartDelta = true;
      } else {
        // 开始转动
        var distance = scrollAxisType == 1 ? dx : -dy;
        if (needStartDelta) {
          distance +=
              (scrollAxisType == 1 ? editingStartXY[0] : -editingStartXY[1]);
        }
        var angle = distance * getCube().rotateRatio;
        scrollAngle += angle;
        setState(() {
          getCube().cameraMovedOnRelative(scrollAxis[scrollAxisType], angle);
        });
      }
      return;
    }

    if (selectedSurface == null) {
      // rotate the whole cube
      // 确定当前滚动的的以哪个轴心滚动
      Vector3 axis = getCameraRotationAxis(details);

      final angle = getCameraRotationAngle(details);
      setState(() {
        getCube().cameraMovedOnRelative(axis, angle);
      });
      totalAngle += angle;
      return;
    }

    // rotate one of the three axes
    Vector3 normal = selectedSurface!.currentNormal(); // surface normal
    Vector3 moveV = Vector3(dx, dy, 0.0); // move vector

    // get the vector in unmoved camera
    // todo double check this formula
    moveV.applyMatrix3(getCube().cameraTransform.getRotation()..invert());

    if (currentAxis == null) {
      List<Vector3> axes = [axisX, axisY, axisZ]..sort((a, b) {
          final aAngleToNormal = (_90Degree - a.angleTo(normal)).abs();
          final bAngleToNormal = (_90Degree - b.angleTo(normal)).abs();

          // decide which axis is more like stand vertical on the surface normal
          if (almostZero(aAngleToNormal - bAngleToNormal)) {
            // this axis is close, then compute the angle between move direction and axis
            return (_90Degree - b.angleTo(moveV))
                .abs()
                .compareTo((_90Degree - a.angleTo(moveV)).abs());
          }

          return bAngleToNormal.compareTo(aAngleToNormal);
        });

      currentAxis = axes.last.clone();
      // search all pieces on the rotating plane
      rotatingPieces = getCube().findPiecesOnSamePlane(
        selectedSurface!.piece,
        currentAxis!,
      );
    }

    // project the move vector to rotating plane, then compute the distance to normal
    moveV = projectOnPlane(moveV, currentAxis!);
    double distance = math.sin(moveV.angleTo(normal)) * moveV.length;

    final pos = moveV.angleToSigned(normal, currentAxis!) < 0 ? 1 : -1;
    final angle = pos * distance * getCube().rotateRatio;
    rotateFaceWithFinger(moveV, normal, angle);
  }

  void rotateFaceWithFinger(Vector3 moveV, Vector3 normal, double angle) {
    setState(() {
      getCube().rotatePieces(currentAxis!, rotatingPieces!, angle);
    });
    totalAngle += angle;
  }

  Vector3 getCameraRotationAxis(DragUpdateDetails details) {
    return Vector3(-details.delta.dy, details.delta.dx, 0)..normalize();
  }

  // 滚动的弧度
  double getCameraRotationAngle(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;
    return math.sqrt(dx * dx + dy * dy) * getCube().rotateRatio;
  }
}

class AutoPlayCubeWidget extends StatefulWidget {
  final Cube cube;
  final EventBus eventBus;

  AutoPlayCubeWidget({required this.cube, required this.eventBus});

  @override
  _AutoPlayCubeWidgetState createState() => _AutoPlayCubeWidgetState();
}

final Map<FaceColor, ui.Image?> cubeFaceImages = {
  FaceColor.YELLOW: null,
  FaceColor.GREEN: null,
  FaceColor.WHITE: null,
  FaceColor.BLUE: null,
  FaceColor.RED: null,
  FaceColor.ORANGE: null,
};

class _AutoPlayCubeWidgetState extends State<AutoPlayCubeWidget>
    with SingleTickerProviderStateMixin {
  Ticker? autoPlayTicker;
  double radian = 0;

  @override
  void initState() {
    super.initState();

    startTicker();

    widget.eventBus.on<AutoPlayEvent>().listen((event) {
      if (event.play) {
        startTicker();
      } else {
        autoPlayTicker?.dispose();
        autoPlayTicker = null;
      }
    });
  }

  void startTicker() {
    autoPlayTicker ??= Ticker((Duration duration) {
      setState(() {
        radian += 0.02;
        final axis = Vector3(
          math.sin(radian) + 1,
          math.sin(radian + math.pi / 2) + 1,
          math.sin(radian + math.pi) + 1,
        );
        widget.cube.cameraMoved(axis, 0.02);
      });
    });
    autoPlayTicker!.start();
  }

  @override
  void dispose() {
    autoPlayTicker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getCubePainter(widget.cube);
  }
}

Vector3 projectOnPlane(Vector3 v, Vector3 normal) {
  // todo double check this formula
  return v - normal * v.dot(normal) / normal.dot(normal);
}

final Paint _blackPaint = Paint()
  ..color = Colors.black
  ..isAntiAlias = true
  ..strokeJoin = StrokeJoin.bevel;

final Paint _imagePaint = Paint();

class CubePainter extends CustomPainter {
  CubePainter(this.cube);

  final Cube cube;

  @override
  void paint(Canvas canvas, Size size) {
    for (var value in cubeFaceImages.values) {
      if (value == null) {
        return;
      }
    }

    // start from the center of the canvas
    canvas.translate(size.width * 0.5, size.height * 0.5);

    // the black background
    Rect surfaceRect = Rect.fromCircle(
      center: Offset.zero,
      radius: cubeFaceImages[FaceColor.RED]!.width * 0.5,
    );

    cube.orderedPaintSurfaces.forEach((ps) {
      final tsf = cube.cameraTransform.multiplied(ps.piece.transform)
        ..multiply(ps.canvasTransform);

      canvas.save();
      canvas.transform(tsf.storage);
      canvas.scale(cube.pieceSize / cubeFaceImages[FaceColor.RED]!.width);

      var text = ps.face.toString().split(".").last;
      var builder = ui.ParagraphBuilder(ui.ParagraphStyle(
          textDirection: TextDirection.ltr,
          fontWeight: FontWeight.normal,
          fontSize: 17))
        ..pushStyle(ui.TextStyle(color: Colors.red))
        ..addText(text);

      var paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: 100));

      canvas.drawRect(surfaceRect, _blackPaint);

      canvas.drawParagraph(
          paragraph,
          surfaceRect.center
              .translate(-(surfaceRect.width / 2 - paragraph.width / 2), 0));

      if (ps.color != FaceColor.BLACK) {
        ui.Image face = cubeFaceImages[ps.color]!;
        canvas.drawImage(
          face,
          Offset(-face.width / 2, -face.height / 2),
          _imagePaint,
        );
      }

      canvas.restore();
    });
  }

  @override
//  bool shouldRepaint(SignaturePainter other) => other.angleX != angleX || other.angleY != angleY;
  bool shouldRepaint(CubePainter other) => true;
}

Widget getCubePainter(Cube cube) {
  return Container(
    color: Colors.transparent,
    child: CubeWidget(
      cube: cube,
    ),
  );
}

//
// Widget getCubePainter(Cube cube) {
//   return CustomPaint(
//     painter: CubePainter(cube),
//     size: Size.infinite,
//   );
// }

int getMoveStep(double angle, double stepAngle) {
  if (angle.isNegative) {
    return -getMoveStep(angle.abs(), stepAngle);
  }

  return (angle + stepAngle / 2) ~/ stepAngle;
}

double getMoveRestoreAngle(double angle, double stepAngle) {
  return getMoveStep(angle, stepAngle) * stepAngle - angle;
}

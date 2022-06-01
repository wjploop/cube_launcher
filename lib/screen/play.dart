import 'dart:math';

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/components/cube.dart';
import 'package:cube_launcher/components/cube_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../generated/l10n.dart';

class PlayScreen extends StatefulWidget {
  @override
  PlayScreenState createState() {
    return PlayScreenState();
  }
}

class PlayScreenState extends State<PlayScreen> with SingleTickerProviderStateMixin {
  bool loaded = false;
  late Cube cube;

  bool inAnimation = false;
  late double animationLastAngle;
  late Vector3 animationAxis;
  late List<CubePiece> animationPieces;

  @override
  void initState() {
    super.initState();

    WidgetsBinding?.instance?.addPostFrameCallback(_afterLayout);

    // loadAppInfo();
  }

  void loadAppInfo() async {
    setState(() {
      loaded = true;
    });
  }

  void _afterLayout(_) async {
    Size screenSize = MediaQuery.of(context).size;
    print('screen size $screenSize');
    double topAreaHeight = min(screenSize.width, screenSize.height);

    double cubeSize = topAreaHeight / 6;

    cube = Cube(pieceSize: cubeSize);

    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    Widget cubeArea;
    if (!context.read<AppData>().hadLoad) {
      cubeArea = LayoutBuilder(
        builder: (context, constraints) => PlayCubeWidget(
          cube: cube,
          touchable: !inAnimation,
        ),
      );
    } else {
      cubeArea = Center(
        child: Text(S.of(context).loading),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/images/cool_bg_1.jpg"),
          )),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: cubeArea,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

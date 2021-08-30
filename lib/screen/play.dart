import 'dart:math';

import 'package:cube_launcher/components/cube.dart';
import 'package:cube_launcher/components/cube_component.dart';
import 'package:cube_launcher/data/Repo.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class PlayScreen extends StatefulWidget {
  @override
  PlayScreenState createState() {
    return PlayScreenState();
  }
}

class PlayScreenState extends State<PlayScreen>
    with SingleTickerProviderStateMixin {
  bool loaded = false;
  late Cube cube;

  EventBus eventBus = EventBus();


  bool inAnimation = false;
  late double animationLastAngle;
  late Vector3 animationAxis;
  late List<CubePiece> animationPieces;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);

    loadAppInfo();
  }

  void loadAppInfo() async {
    await Repo.init();
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
    if (loaded) {
      cubeArea = LayoutBuilder(
        builder: (context, constraints) => PlayCubeWidget(
          cube: cube,
          touchable: !inAnimation,
        ),
      );
    } else {
      cubeArea = Center(
        child: Text("loading"),
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

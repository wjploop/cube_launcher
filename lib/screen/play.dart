import 'dart:async';
import 'dart:math' as math;
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

  late AnimationController shuffleController;

  bool inAnimation = false;
  late double animationLastAngle;
  late Vector3 animationAxis;
  late List<CubePiece> animationPieces;

  bool waitInitShuffle = true;
  bool showFinished = false;

  @override
  void initState() {
    super.initState();

    shuffleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: math.pi / 2,
      vsync: this,
    );
    shuffleController.addListener(() {
      setState(() {
        cube.rotatePieces(
          animationAxis,
          animationPieces,
          shuffleController.value - animationLastAngle,
        );
        animationLastAngle = shuffleController.value;
        // The state that has changed here is the animation object’s value.
      });
    });

    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);

    loadAppInfo();

  }

  void loadAppInfo() async{
     await Repo.init();
     setState(() {
       loaded =true;
     });

  }

  void _afterLayout(_) async {
    Size screenSize = MediaQuery.of(context).size;
    double cubeSize = min(screenSize.width, screenSize.height) / 6;
    cube = Cube(pieceSize: cubeSize);

    setState(() {});

    await shuffle();

    setState(() {
      waitInitShuffle = false;
    });
  }

  Future<Null> shuffle([int steps = 20]) async {
    if (inAnimation) {
      return;
    }
    inAnimation = true;
    while (steps > 0) {
      steps--;

      final rng = math.Random();
      animationAxis = Vector3.all(0)..[rng.nextInt(3)] = 1;

      final corners = const [0, 2, 6, 8, 18, 20, 24, 26];
      final i = rng.nextInt(8);
      final piece = cube.positionMap[corners[i]]!;
      animationLastAngle = 0;
      animationPieces = cube.findPiecesOnSamePlane(piece, animationAxis);

      await shuffleController.forward(from: animationLastAngle);
      cube.rotatePiecePositions(animationAxis, 1, animationPieces);
    }
    inAnimation = false;
  }

  @override
  void dispose() {
    shuffleController.stop();
    shuffleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget cubeArea;
    if(loaded) {
      cubeArea = PlayCubeWidget(
          cube: cube, touchable: !inAnimation, eventBus: eventBus);
    }else{
      cubeArea = Center(child: Text("loading"),);
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Container(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          ElevatedButton(
                            child: Text(
                              "RESTART",
                              style: TextStyle(fontSize: 12),
                            ),
                            onPressed: () async {
                              if (inAnimation) {
                                return;
                              }

                              cube.reset();
                              setState(() {
                                waitInitShuffle = true;
                                showFinished = false;
                              });
                              await shuffle();
                              setState(() {
                                waitInitShuffle = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
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

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/components/cube_component.dart';
import 'package:cube_launcher/screen/area_top_bottom.dart';
import 'package:cube_launcher/screen/play.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp( App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "cube launcher",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => AppData(),
        child: AreaTopBottom(),
      )
    );
  }
}


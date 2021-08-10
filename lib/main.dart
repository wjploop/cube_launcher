import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/screen/area_top_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/Repo.dart';

void main() {
  runApp(App());
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
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => AppData(),
            ),
            ChangeNotifierProvider(
              create: (context) => EditingState(false),
            ),
            ChangeNotifierProvider(
              create: (context) => FaceColorMap(Repo.map),
            ),
          ],
          child: Scaffold(
              body: Container(color: Colors.blue, child: AreaTopBottom())),
        ));
  }
}

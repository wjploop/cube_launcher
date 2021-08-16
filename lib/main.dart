import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/screen/area_top_bottom.dart';
import 'package:event_bus/event_bus.dart';
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
          primaryColor: Colors.white,
        ),
        home: MultiProvider(
          providers: [
            Provider(
              create: (context) => EventBus(),
            ),
            ChangeNotifierProvider(
              create: (context) => AppData(),
            ),
            ChangeNotifierProvider(
              create: (context) => MenuState(MenuPosition.top, false),
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

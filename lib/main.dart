import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/screen/area_top_bottom.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "cube launcher",
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
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
          ],
          child: Scaffold(
              body: Container(color: Colors.blue, child: AreaTopBottom())),
        ));
  }
}

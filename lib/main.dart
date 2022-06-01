import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/screen/area_top_bottom.dart';
import 'package:cube_plugin/cube_plugin.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';

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
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
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
              body: WillPopScope(
                  onWillPop: () async {
                    var isSet = await CubePlugin.isSetLauncherToSelf;
                    // if set launcher to current app, consume this back button
                    print('onWillPop isSetLauncher: $isSet');
                    return !isSet;
                  },
                  child: Container(color: Colors.blue, child: AreaTopBottom()))),
        ));
  }
}

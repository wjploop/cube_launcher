import 'dart:ui';

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/components/cube.dart';
import 'package:cube_launcher/data/AppInfo.dart';
import 'package:cube_launcher/data/Repo.dart';
import 'package:cube_launcher/data/event.dart';
import 'package:cube_launcher/screen/area_top_bottom.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppGalley extends StatefulWidget {
  const AppGalley({Key? key}) : super(key: key);

  @override
  _AppGalleyState createState() => _AppGalleyState();
}

class _AppGalleyState extends State<AppGalley> {
  bool showAction = false;

  @override
  void initState() {
    super.initState();
    loading();
  }

  void loading() async {
    await Repo.init();
    context.read<AppData>().loaded();
    Future.delayed(Duration(seconds: 2), () {
      context.read<MenuState>().update(MenuPosition.middle, false);
    });
  }

  Widget menuActionToWidget(MenuState state, MenuAction action) {
    var icon = action == MenuAction.action_arrow_up
        ? Icons.arrow_circle_up_rounded
        : action == MenuAction.action_arrow_down
            ? Icons.arrow_circle_down_rounded
            : action == MenuAction.action_editing_cube
                ? Icons.edit_rounded
                : action == MenuAction.action_choose_color
                    ? Icons.color_lens_rounded
                    : throw Exception("no support action");

    void statePrev() {
      state.update(prev(state.position), false);
      setState(() {
        showAction = false;
      });
    }

    void stateNext() {
      state.update(next(state.position), false);
      setState(() {
        showAction = false;
      });
    }

    void stateEdit() {
      context.read<EventBus>().fire(RotateToEditEvent());
      state.update(state.position, !state.edit);
    }

    void stateColorSelect() async {
      var faceColorMap = context.read<FaceColorMap>();

      final Color colorBeforeDialog = faceColorMap.colorMap[FaceColor.RED]!;
      if (!(await colorPickerDialog())) {
        updateFaceColor(FaceColor.RED, colorBeforeDialog);
      }
    }

    void emptyAction() {}

    var actionFun = action == MenuAction.action_arrow_up
        ? statePrev
        : action == MenuAction.action_arrow_down
            ? stateNext
            : action == MenuAction.action_editing_cube
                ? stateEdit
                : action == MenuAction.action_choose_color
                    ? stateColorSelect
                    : emptyAction;

    return IconButton(
        onPressed: () {
          actionFun();
        },
        icon: Icon(icon, color: Colors.white));
  }

  void updateFaceColor(FaceColor face, Color color) {
    var faceColorMap = context.read<FaceColorMap>();
    var colorMap = faceColorMap.colorMap;
    var newMap = Map.of(colorMap)..[face] = color;
    faceColorMap.updateColor(newMap);
  }

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      color:
          context.read<FaceColorMap>().colorMap[FaceColor.RED] ?? Colors.yellow,
      onColorChanged: (Color color) {
        updateFaceColor(FaceColor.RED, color);
      },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      pickerTypeLabels: {ColorPickerType.primary: "主要"},
      actionButtons: ColorPickerActionButtons(),
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
      customColorSwatchesAndNames: colorsNameMap,
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 320, minWidth: 300, maxWidth: 320),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 46,
          color: Colors.deepPurple,
          child: Stack(
            children: [
              Center(
                child: Text("Cube Launcher"),
              ),
              Row(
                children: [
                  Expanded(
                      child: Visibility(
                    visible: showAction,
                    child: Container(
                      color: Colors.deepPurple,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: context
                              .read<MenuState>()
                              .actions()
                              .map((e) => menuActionToWidget(
                                  context.read<MenuState>(), e))
                              .toList()),
                    ),
                  )),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          showAction = !showAction;
                        });
                      },
                      icon: Icon(
                        Icons.more_horiz,
                        size: 26,
                      )),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<AppData>(
            builder: (context, appdata, child) {
              if (!appdata.hadLoad) {
                return Container(
                  child: Center(
                    child: Text(
                      "Loading...",
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                );
              }
              return GridView.count(
                  crossAxisCount: 5,
                  childAspectRatio: 0.6,
                  padding: EdgeInsets.all(8),
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 10,
                  children: Repo.apps.map((e) => GalleryItem(app: e)).toList());
            },
          ),
        ),
      ],
    );
  }
}

class GalleryItem extends StatelessWidget {
  final AppInfo app;

  const GalleryItem({Key? key, required this.app}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var iconSize = screenSize.width / 5 - 26;
    return LongPressDraggable(
      data: app,
      feedback: ClipOval(
        child: Image.memory(
          app.icon,
          width: iconSize,
          height: iconSize,
        ),
      ),
      child: Container(
        height: iconSize * 3,
        width: iconSize,
        child: Center(
          child: Column(
            children: [
              Container(
                child: ClipOval(
                  child: Image.memory(
                    app.icon,
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  "${app.name}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Define some custom colors for the custom picker segment.
// The 'guide' color values are from
// https://material.io/design/color/the-color-system.html#color-theme-creation
const Color guidePrimary = Color(0xFF6200EE);
const Color guidePrimaryVariant = Color(0xFF3700B3);
const Color guideSecondary = Color(0xFF03DAC6);
const Color guideSecondaryVariant = Color(0xFF018786);
const Color guideError = Color(0xFFB00020);
const Color guideErrorDark = Color(0xFFCF6679);
const Color blueBlues = Color(0xFF174378);
// Make a custom ColorSwatch to name map from the above custom colors.
final Map<ColorSwatch<Object>, String> colorsNameMap =
    <ColorSwatch<Object>, String>{
  ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
  ColorTools.createPrimarySwatch(guidePrimaryVariant): 'Guide Purple Variant',
  ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
  ColorTools.createAccentSwatch(guideSecondaryVariant): 'Guide Teal Variant',
  ColorTools.createPrimarySwatch(guideError): 'Guide Error',
  ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
  ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
};
import 'package:cube_launcher/screen/area_top_bottom.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class FaceColorPicker extends StatelessWidget {
  const FaceColorPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ColorPicker(
        color: context
            .read<FaceMap>()
            .colorMap[context.read<MenuState>().editFace]!,
        onColorChanged: (color) {
          var faceColorMap = context.read<FaceMap>();
          var face = context.read<MenuState>().editFace;
          var colorMap = faceColorMap.colorMap;
          var newMap = Map.of(colorMap)..[face] = color;
          faceColorMap.updateColor(newMap);
        },
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.both: false,
          ColorPickerType.primary: false,
          ColorPickerType.accent: false,
          ColorPickerType.bw: false,
          ColorPickerType.custom: false,
          ColorPickerType.wheel: true,
        },
      ),
    );
  }
}

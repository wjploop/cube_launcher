import 'dart:collection';

import 'package:cube_launcher/components/cube.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix3, Vector3;

String standardMatrix3(Matrix3 matrix3) {
  return matrix3.storage.map((double e) {
    var onlyInt = e.toStringAsFixed(0);
    var res = "0";
    if (onlyInt.contains('0')) {
      res = "0";
    } else {
      res = onlyInt;
    }
    return res;
  }).join(" ");
}

String standardMatrix3Format(Matrix3 matrix3) {
  var str = matrix3.storage.map((double e) {
    var onlyInt = e.toStringAsFixed(0);
    var res = "0";
    if (onlyInt.contains('0')) {
      res = "0";
    } else {
      res = onlyInt;
    }
    return res;
  }).toList();
  String res = "";

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      res += "${str[i * 3 + j]} ";
    }
    res += "\n";
  }
  return res;
}

const standardRotation = {
  FaceColor.RED: [
    "1 0 0 0 1 0 0 0 1",
    "0 1 0 -1 0 0 0 0 1",
    "-1 0 0 0 -1 0 0 0 1",
    "0 -1 0 1 0 0 0 0 1",
  ],
  FaceColor.YELLOW: [
    "0 -1 0 0 0 1 -1 0 0",
    "1 0 0 0 0 1 0 -1 0",
    "0 1 0 0 0 1 1 0 0",
    "-1 0 0 0 0 1 0 1 0",
  ],
  FaceColor.GREEN: [
    "0 0 -1 -1 0 0 0 1 0",
    "0 0 -1 0 -1 0 -1 0 0",
    "0 0 -1 1 0 0 0 -1 0",
    "0 0 -1 0 1 0 1 0 0",
  ],
  FaceColor.ORANGE: [
    '-1 0 0 0 1 0 0 0 -1',
    "0 -1 0 -1 0 0 0 0 -1",
    "1 0 0 0 -1 0 0 0 -1",
    "0 1 0 1 0 0 0 0 -1",
  ],
  FaceColor.BLUE: [
    "0 0 1 -1 0 0 0 -1 0",
    "0 0 1 0 -1 0 1 0 0",
    "0 0 1 1 0 0 0 1 0",
    "0 0 1 0 1 0 -1 0 0",
  ],
  FaceColor.WHITE: [
    "-1 0 0 0 0 -1 0 -1 0",
    "0 -1 0 0 0 -1 1 0 0",
    "1 0 0 0 0 -1 0 1 0",
    "0 1 0 0 0 -1 -1 0 0",
  ]
};

void main() {
  // test data
  var set = HashSet();
  standardRotation.forEach((key, value) {
    value.forEach((angel) {
      if (set.contains(angel)) {
        print('error duplicate angel: $angel');
        return;
      }
      set.add(angel);
    });
  });
}

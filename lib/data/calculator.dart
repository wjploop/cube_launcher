import 'dart:math';

import 'package:flutter/cupertino.dart';

void main() {}

// 0 - 2pi 分为四个区域，如下

// [0, pi/4] || [2pi - pi/4, 2pi]
// [pi/2 - pi/4, pi/2+pi/4]
// [pi - pi/4, pi + pi/4]
// [3pi/2 - pi/4, 3pi/2 + pi/4]

double angelX(Matrix4 matrix4) {
  return calculateX(sinx(matrix4), cosx(matrix4));
}

double angelY(Matrix4 matrix4) {
  return calculateX(siny(matrix4), cosy(matrix4));
}

double angelZ(Matrix4 matrix4) {
  return calculateX(sinz(matrix4), cosz(matrix4));
}

/**
 *  x  = (0, 2pi)
 *
 */
double calculateX(double sinx, double cosx) {
  // 转为锐角 0 - pi/2

  // 确定在哪个象限
  int index = 0;
  if (sinx >= 0 && cosx >= 0) {
    index = 0;
  } else if (sinx >= 0 && cosx <= 0) {
    index = 1;
  } else if (sinx <= 0 && cosx <= 0) {
    index = 2;
  } else if (sinx <= 0 && cosx >= 0) {
    index = 3;
  }

  // asinx 定义域为 (-pi/2, pi/2)
  // 且, (0,pi/2)时，其值 > 0, 故取其绝对值计算
  var absSinx = sinx.abs();

  // 锐角
  var x = asin(absSinx);

  return x + index * pi / 2;
}

/**
 * 参考 https://medium.com/flutter-community/advanced-flutter-matrix4-and-perspective-transformations-a79404a0d828
 *
 *  1    0    0    0
 *  0   cosx sinx  0
 *  0  -sinx cosx  0
 *  0    0    0    1
 */

double sinx(Matrix4 matrix4) {
  return matrix4.storage[6] / matrix4.storage[0];
}

double cosx(Matrix4 matrix4) {
  return matrix4.storage[10] / matrix4.storage[0];
}

double siny(Matrix4 matrix4) {
  return matrix4.storage[8] / matrix4.storage[5];
}

double cosy(Matrix4 matrix4) {
  return matrix4.storage[10] / matrix4.storage[5];
}

double sinz(Matrix4 matrix4) {
  return matrix4.storage[1] / matrix4.storage[10];
}

double cosz(Matrix4 matrix4) {
  return matrix4.storage[5] / matrix4.storage[10];
}

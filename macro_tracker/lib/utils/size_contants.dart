import 'package:flutter/material.dart';

class AppSpacing {
  static const double medium = 16;
  static const double large = 32;
}

class SizedBoxWithWidth {
  static const SizedBox small = SizedBox(width: 5);
  static const SizedBox medium = SizedBox(width: 10);
  static const SizedBox large = SizedBox(width: 15);
  static const SizedBox xLarge = SizedBox(width: 20);
  static const SizedBox xxLarge = SizedBox(width: 34);
}

class SizedBoxWithHeight {
  static const SizedBox small = SizedBox(height: 5);
  static const SizedBox medium = SizedBox(height: 10);
  static const SizedBox large = SizedBox(height: 15);
  static const SizedBox xLarge = SizedBox(height: 20);
  static const SizedBox xxLarge = SizedBox(height: 34);
}

class EdgeInsetsAll {
  static const EdgeInsets medium = EdgeInsets.all(AppSpacing.medium);
  static const EdgeInsets large = EdgeInsets.all(AppSpacing.large);
}

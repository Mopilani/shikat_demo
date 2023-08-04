
import 'package:flutter/material.dart';

class ScreenItem {
  ScreenItem(
    this.routeWidget,
    this.title,
    this.desctiption, {
    this.icon,
    this.imagePath,
  });

  Widget? routeWidget;
  String title;
  IconData? icon;
  String? imagePath;
  String desctiption;
}

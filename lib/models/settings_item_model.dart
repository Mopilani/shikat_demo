import 'package:flutter/material.dart';

class SettingsItem {
  SettingsItem({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
  });

  final Widget route;
  final IconData icon;
  final String title;
  final String subtitle;
}

import 'package:flutter/material.dart';
import 'package:shikat/main.dart';
import 'package:shikat/models/ornik_model.dart';
import 'package:shikat/models/shik_model.dart';
import 'package:shikat/models/system_config.dart';

class ThemeSettingsView extends StatefulWidget {
  const ThemeSettingsView({Key? key}) : super(key: key);

  @override
  State<ThemeSettingsView> createState() => _ThemeSettingsViewState();
}

class _ThemeSettingsViewState extends State<ThemeSettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الثيم'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Light'),
            onTap: () {
              ThemeUpdater().add(buildTheme(Brightness.light));
              SystemConfig().theme = 'light';
            },
          ),
          ListTile(
            title: const Text('Dark'),
            onLongPress: () {
              OrnikModel.deleteAll();
            },
            onTap: () {
              ThemeUpdater().add(buildTheme(Brightness.dark));
              SystemConfig().theme = 'dark';
            },
          ),
        ],
      ),
    );
  }
}

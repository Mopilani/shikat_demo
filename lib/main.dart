import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shikat/messages.dart';
import 'package:shikat/views/home_page.dart';
import 'package:updater/updater.dart' as updater;
import 'package:overlay_support/overlay_support.dart';

import 'initial_data.dart';
import 'models/system_config.dart';
import 'utils/esc_utils/print_model.dart';
import 'utils/system_db.dart';

List errors = [];
List stacksTracess = [];
String? timeError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    // GlobalState.set('firebaseApp', app);
    await SystemMDBService().init();
    // MongoDBService().init();
  } catch (e, s) {
    errors.add(e);
    stacksTracess.add(s);
    // throw s;
  }

  // try {
  //   await timeSensor();
  // } catch (e, s) {
  //   errors.add(e);
  //   stacksTracess.add(s);
  //   // throw s;
  // }

  var r = await SystemConfig.get();
  try {
    print(r!.asMap());
  } catch (e) {
    var ins = SystemConfig.init();
    ins.printer = 'Microsoft Print to PDF';
    ins.invoicesSaveDirectoryPath = await ins.getUserDocumentsPath();
    ins.theme = 'light';
    await ins.add();
  }

  if (Platform.isWindows) {
    // restartMongoDBService();
    try {
      await PrintServiceModel.init(SystemConfig().printer);
    } catch (e, s) {
      errors.add(e);
      stacksTracess.add(s);
      // throw s;
    }

    try {
      await CapabilityProfile.load();
    } catch (e, s) {
      errors.add(e);
      stacksTracess.add(s);
      // throw s;
    }
  }

  try {
    // GlobalState.set('firebaseApp', app);
    await initialData();
  } catch (e, s) {
    errors.add(e);
    stacksTracess.add(s);
    // throw s;
  }

  runApp(
    OverlaySupport.global(
      child: updater.UpdaterBloc<ThemeData>(
        updater: ThemeUpdater(
          init: SystemConfig().theme == 'light'
              ? buildTheme(Brightness.light)
              : buildTheme(Brightness.dark),
          updateForCurrentEvent: true,
        ),
        update: (context, state) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            translations: Messages(), // your translations
            locale: const Locale('ar', 'SD'),
            fallbackLocale: const Locale('en', 'UK'),
            theme: state.data ?? buildTheme(Brightness.light),
            home: const MyHomePage(title: 'Businet Shikat'),
          );
        },
      ),
    ),
  );
}

late Locale contextLocale;

class ThemeUpdater extends updater.Updater {
  ThemeUpdater({
    init,
    bool updateForCurrentEvent = false,
  }) : super(init, updateForCurrentEvent: updateForCurrentEvent);
}

ThemeData buildTheme(
  brightness, {
  String fontFamily = 'cairo',
  Color? primaryColor,
  ColorScheme? colorScheme,
}) {
  String fontFam = fontFamily;
  var baseTheme = ThemeData(
    primaryColor: primaryColor,
    brightness: brightness,
    colorScheme: colorScheme ??
        ColorScheme(
          brightness: brightness,
          error: Colors.red,
          onError: brightness == Brightness.dark ? Colors.white : Colors.black,
          surface: primaryColor?.withOpacity(.8) ?? Colors.blue,
          onSurface:
              brightness == Brightness.dark ? Colors.white : Colors.black,
          background: primaryColor?.withOpacity(.5) ?? Colors.blue,
          onBackground:
              brightness == Brightness.dark ? Colors.white : Colors.white,
          secondary: primaryColor?.withOpacity(.7) ?? Colors.blue,
          onSecondary:
              brightness == Brightness.dark ? Colors.white : Colors.white,
          tertiary: primaryColor?.withOpacity(.8) ?? Colors.blue,
          onTertiary:
              brightness == Brightness.dark ? Colors.white : Colors.white,
          primary: primaryColor?.withOpacity(.9) ?? Colors.blue,
          onPrimary:
              brightness == Brightness.dark ? Colors.white : Colors.white,
          // tertiary: ,
        ),
    textTheme: TextTheme(
      displaySmall: TextStyle(fontFamily: fontFam),
      displayMedium: TextStyle(fontFamily: fontFam),
      labelLarge: TextStyle(fontFamily: fontFam),
      bodyLarge: TextStyle(fontFamily: fontFam),
      bodyMedium: TextStyle(fontFamily: fontFam),
      bodySmall: TextStyle(fontFamily: fontFam),
      labelMedium: TextStyle(fontFamily: fontFam),
      labelSmall: TextStyle(fontFamily: fontFam),
      titleLarge: TextStyle(fontFamily: fontFam),
      titleMedium: TextStyle(fontFamily: fontFam),
      titleSmall: TextStyle(fontFamily: fontFam),
      displayLarge: TextStyle(fontFamily: fontFam),
    ),
    primaryTextTheme: TextTheme(
      displaySmall: TextStyle(fontFamily: fontFam),
      displayMedium: TextStyle(fontFamily: fontFam),
      labelLarge: TextStyle(fontFamily: fontFam),
      bodyLarge: TextStyle(fontFamily: fontFam),
      bodyMedium: TextStyle(fontFamily: fontFam),
      bodySmall: TextStyle(fontFamily: fontFam),
      labelMedium: TextStyle(fontFamily: fontFam),
      labelSmall: TextStyle(fontFamily: fontFam),
      titleLarge: TextStyle(fontFamily: fontFam),
      titleMedium: TextStyle(fontFamily: fontFam),
      titleSmall: TextStyle(fontFamily: fontFam),
      displayLarge: TextStyle(fontFamily: fontFam),
    ),
  );

  return baseTheme;
}

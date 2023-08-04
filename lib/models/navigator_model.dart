

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:overlay_support/overlay_support.dart';

import 'system_config.dart';
import 'user_model.dart';

Map<String, SystemRouteModel> systemRoutes = {
  // 'WelcomeScreen': SystemRouteModel(
  //     'KDEWelcomeScreenYaMKNA', 0, 'WelcomeScreen',
  //     runtimeType0: WelcomeScreen),
};

class SysNav {
  SysNav() {
    // systemRoutes.addAll({});
  }

  static SystemRouteModel? look(Type type) {
    return systemRoutes[type];
  }

  static UserModel registerRoutesForUser(
      UserModel user, List<Type> routesTypes) {
    for (var type in routesTypes) {
      if (systemRoutes[type.toString()] == null) {
        throw 'Unregistered System Route';
      }
      user.accessLevelModel!.allowedLevels.addAll(
        systemRoutes[type.toString()]!.toMap(),
      );
    }
    return user;
  }

  static Future<T?> push<T>(BuildContext context, Widget routeWidget) async {
    var route = systemRoutes[routeWidget.runtimeType.toString()];
    if (route == null) {
      throw Exception(
        'Unexpected routeWidget runtime type'
        ' ${routeWidget.runtimeType.toString()} \n'
        'The route has not been registered',
      );
    }
    route.routeWidget = routeWidget;
    // print(UserModel.stored!.toMap());
    // print(routeWidget.runtimeType);
    // print(allowedLevels.containsKey('SalesPage'));
    // print('444 =========== $allowedLevels');
    // print('444 =========== ${allowedLevels[routeWidget.runtimeType.toString()]}');
    Map<String, dynamic> allowedLevels =
        UserModel.stored!.accessLevelModel!.allowedLevels;
    var systemRouteData = allowedLevels[routeWidget.runtimeType.toString()];
    if (systemRouteData == null) {
      // toast('Route No Found For You');
      toast('Perm Denied Er:1');
      return null;
    }
    SystemRouteModel level = SystemRouteModel.fromMap(systemRouteData);
    if (level.neededAccessToken == route.neededAccessToken) {
      return await Navigator.push<T>(
        context,
        SystemConfig().pageRoute == 'CupertinoPageRoute'
            ? CupertinoPageRoute(
                builder: (context) => route.routeWidget!,
              )
            : MaterialPageRoute(
                builder: (context) => route.routeWidget!,
              ),
      );
    } else {
      toast('Perm Denied');
    }
    return null;
  }

  static void pop<T>(BuildContext context, [T? result]) {
    return Navigator.pop<T>(context, result);
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget routeWidget, {
    TO? result,
  }) async {
    var route = systemRoutes[routeWidget.runtimeType.toString()];
    if (route == null) {
      throw Exception(
        'Unexpected routeWidget runtime type'
        ' ${routeWidget.runtimeType.toString()} \n'
        'The route has not been registered',
      );
    }
    route.routeWidget = routeWidget;
    Map<String, dynamic> allowedLevels =
        UserModel.stored!.accessLevelModel!.allowedLevels;
    var systemRouteData = allowedLevels[routeWidget.runtimeType.toString()];
    if (systemRouteData == null) {
      toast('Perm Denied Er:1');
      return null;
    }
    SystemRouteModel level = SystemRouteModel.fromMap(systemRouteData);
    if (level.neededAccessToken == route.neededAccessToken) {
      return await Navigator.pushReplacement<T, TO>(
        context,
        SystemConfig().pageRoute == 'CupertinoPageRoute'
            ? CupertinoPageRoute(
                builder: (context) => route.routeWidget!,
              )
            : MaterialPageRoute(
                builder: (context) => route.routeWidget!,
              ),
      );
    } else {
      toast('Perm Denied');
    }
    return null;
  }

  // static mainDrawerNavigator(
  //   PageController scrollCont,
  //   PageController sideBarScrollCont,
  //   DrawerItem item,
  //   DrawerItemWidget itemWidget,
  // ) {
  //   bool typeNameFound = false;
  //   SystemRouteModel? route;
  //   for (var value in systemRoutes.values) {
  //     if (drawerItems[item.index].widgetRuntimeType.toString() ==
  //         value.runtimeTypeName) {
  //       typeNameFound = true;
  //       route = value;
  //     }
  //   }
  //   if (!typeNameFound) {
  //     throw (Exception(
  //       'Unexpected routeWidget runtime type'
  //       ' ${drawerItems[item.index].title.runtimeType.toString()} \n'
  //       'The route has not been registered',
  //     ));
  //   }
  //   Map<String, dynamic> allowedLevels =
  //       UserModel.stored!.accessLevelModel!.allowedLevels;
  //   var systemRouteData =
  //       allowedLevels[drawerItems[item.index].widgetRuntimeType.toString()];
  //   if (systemRouteData == null) {
  //     toast('Perm Denied Er:1');
  //     return null;
  //   }
  //   SystemRouteModel level = SystemRouteModel.fromMap(systemRouteData);
  //   if (level.neededAccessToken == route!.neededAccessToken) {
  //     if (SystemConfig().animations) {
  //       scrollCont.animateToPage(
  //         item.index,
  //         duration: const Duration(milliseconds: 200),
  //         curve: Curves.easeIn,
  //       );
  //       sideBarScrollCont.animateToPage(
  //         item.index,
  //         duration: const Duration(milliseconds: 200),
  //         curve: Curves.easeIn,
  //       );
  //     } else {
  //       scrollCont.jumpToPage(
  //         item.index,
  //       );
  //       sideBarScrollCont.jumpToPage(
  //         item.index,
  //       );
  //     }
  //     currentIndex = item.index;
  //     currentSideBarIndex = item.index;
  //     DrawerItemsUpdater().add([
  //       item.index,
  //     ]);
  //   }
  // }

  static Future<T?> pushAndRemoveUntil<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget routeWidget, {
    TO? result,
    bool eznNeeded = true,
  }) async {
    var route = systemRoutes[routeWidget.runtimeType.toString()];
    if (route == null) {
      throw Exception(
        'Unexpected routeWidget runtime type'
        ' ${routeWidget.runtimeType.toString()} \n'
        'The route has not been registered',
      );
    }
    route.routeWidget = routeWidget;
    if (!eznNeeded) {
      return await Navigator.pushAndRemoveUntil<T>(
        context,
        SystemConfig().pageRoute == 'CupertinoPageRoute'
            ? CupertinoPageRoute(
                builder: (context) => route.routeWidget!,
              )
            : MaterialPageRoute(
                builder: (context) => route.routeWidget!,
              ),
        (route) => false,
      );
    }
    Map<String, dynamic> allowedLevels =
        UserModel.stored!.accessLevelModel!.allowedLevels;
    var systemRouteData = allowedLevels[routeWidget.runtimeType.toString()];
    if (systemRouteData == null) {
      toast('Perm Denied Er:1');
      return null;
    }
    SystemRouteModel level = SystemRouteModel.fromMap(systemRouteData);
    if (level.neededAccessToken == route.neededAccessToken) {
      return await Navigator.pushAndRemoveUntil<T>(
        context,
        SystemConfig().pageRoute == 'CupertinoPageRoute'
            ? CupertinoPageRoute(
                builder: (context) => route.routeWidget!,
              )
            : MaterialPageRoute(
                builder: (context) => route.routeWidget!,
              ),
        (route) => false,
      );
    } else {
      toast('Perm Denied');
    }
    return null;
  }
}

class SystemRouteModel {
  SystemRouteModel(
    this.neededAccessToken,
    this.neededAccessLevelNumber,
    this.runtimeTypeName, {
    this.routeWidget,
    required this.runtimeType0,
  });
  late String neededAccessToken;
  late int neededAccessLevelNumber;
  late Widget? routeWidget;
  late String runtimeTypeName;

  late Type? runtimeType0;

  Map<String, dynamic> toMap() => {
        runtimeTypeName: {
          'neededAccessToken': neededAccessToken,
          'neededAccessLevelNumber': neededAccessLevelNumber,
          'runtimeTypeName': runtimeTypeName,
          // 'runtimeType': runtimeType,
        }
      };

  static fromMap(Map<String, dynamic> data) => SystemRouteModel(
        data['neededAccessToken'],
        data['neededAccessLevelNumber'],
        data['runtimeTypeName'],
        runtimeType0: null,
      );
}

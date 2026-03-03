import 'package:flutter/material.dart';

class Nav {

  static RouteObserver<ModalRoute<dynamic>> routeObserver = RouteObserver<ModalRoute<dynamic>>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static navigateToWidget({required Widget view, BuildContext? context}) {
    try {
      Navigator.push(
        routeObserver.navigator!.context,
        PageRouteBuilder(
          pageBuilder: (context, __, ___) => view,
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static navigateAndWait({required Widget view}) async {
    try {
      return await Navigator.push(
        routeObserver.navigator!.context,
        PageRouteBuilder(
          pageBuilder: (context, __, ___) => view,
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static navigateAndReplace({required Widget view, BuildContext? context}) {
    try {
      Navigator.pushReplacement(
        routeObserver.navigator!.context,
        PageRouteBuilder(
          pageBuilder: (context, __, ___) => view,
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static navigateAndReplaceAll({required Widget view, BuildContext? context}) {
    try {
      Navigator.pushAndRemoveUntil(
        routeObserver.navigator!.context,
        PageRouteBuilder(
          pageBuilder: (context, __, ___) => view,
          transitionDuration: const Duration(seconds: 0),
        ),
            (route) => false,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
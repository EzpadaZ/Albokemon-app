import 'package:albokemon_app/app/login/view.dart';
import 'package:albokemon_app/l10n/app_localizations.dart';
import 'package:albokemon_app/shared/utils/device.dart';
import 'package:albokemon_app/shared/utils/game_manager.dart';
import 'package:albokemon_app/shared/utils/locale.dart';
import 'package:albokemon_app/shared/utils/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GameManager.instance.init();
  Device.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameManager.instance,
      builder: (_, __) {
        return MaterialApp(
          title: 'Albokémon',
          debugShowCheckedModeBanner: false,
          navigatorObservers: [Nav.routeObserver],
          locale: GameManager.instance.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('es')],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: const LoginView(),
        );
      },
    );
  }
}

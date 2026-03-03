import 'package:albokemon_app/shared/network/client.dart';
import 'package:albokemon_app/shared/network/session.dart';
import 'package:flutter/material.dart';

class GameManager extends ChangeNotifier {
  GameManager._();
  static final GameManager instance = GameManager._();

  late SocketClient socket;
  late Session session;

  String? assignedId;

  bool _init = false;

  double music_volume = 0.2;
  //String connectionString = "https://albokemon-backend-468858143339.us-central1.run.app/";
  String connectionString = "http://192.168.3.201:8080";

  // --- Locale ---
  Locale? _locale; // null = follow system
  Locale? get locale => _locale;

  void setLocale(Locale? value) {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
  }

  void setConnectionString(String url) {
    connectionString = url.trim();
    if (connectionString.isEmpty) return;

    // if already initialized, rebuild client/session with new URL
    if (_init) {
      session.reset();
      socket.dispose();
      _init = false;
    }
  }

  Locale effectiveLocale(BuildContext context) =>
      _locale ?? Localizations.localeOf(context);

  String localeCode(BuildContext context) =>
      effectiveLocale(context).languageCode;

  String localeLabel(BuildContext context) {
    switch (localeCode(context)) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return localeCode(context);
    }
  }

  void nextLocale(BuildContext context) {
    final code = localeCode(context);
    setLocale(code == 'en' ? const Locale('es') : const Locale('en'));
  }

  void prevLocale(BuildContext context) => nextLocale(context); // 2 locales

  // --- Network ---
  void init() {
    if (_init) return;
    socket = SocketClient(connectionString);
    session = Session(socket);
    _init = true;
  }

  void disconnect() {
    assignedId = null;

    session.reset();
    socket.disconnect();
    socket.dispose();
    _init = false;
  }
}
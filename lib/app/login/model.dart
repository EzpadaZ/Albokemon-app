import 'dart:async';

import 'package:albokemon_app/app/lobby/view.dart';
import 'package:albokemon_app/shared/utils/audio.dart';
import 'package:albokemon_app/shared/utils/game_manager.dart';
import 'package:albokemon_app/shared/utils/logger.dart';
import 'package:albokemon_app/shared/utils/nav.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  bool isConnected = false;

  String username = "";

  bool _busy = false;

  execute() async {
    Logger.instance.info("Is Busy: $_busy");
    if (_busy) return;
    _busy = true;

    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      error = "Se requiere un nombre de usuario.";
      notifyListeners();
      _busy = false;
      return;
    }

    error = null;
    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      await connect();
      isConnected = true;
      notifyListeners();
      Audio.instance.playLoop('assets/bgm/menu.mp3', volume: 0.5);
      await Future.delayed(const Duration(seconds: 2));
      await login(trimmed);
      Nav.navigateToWidget(view: const LobbyView());
    } catch (e) {
      Logger.instance.error("Login execute failed", e);
      error = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
      _busy = false;
    }
  }

  login(String name) async {
    final session = GameManager.instance.session;
    session.initListeners();

    if (session.me.value != null) return;

    session.login(name);

    await _waitValue<Map<String, dynamic>?>(
      listenable: session.me,
      predicate: (v) => v != null,
      timeout: const Duration(seconds: 6),
      timeoutMessage: "Login timed out",
    );

    Logger.instance.info("Logged In");
  }

  connect() async {
    final socket = GameManager.instance.socket;
    socket.connect(); // idempotent in our wrapper

    if (socket.isConnected.value) return;

    await _waitValue<bool>(
      listenable: socket.isConnected,
      predicate: (v) => isConnected = v,
      timeout: const Duration(seconds: 6),
      timeoutMessage: "Connection timed out",
    );
  }

  _waitValue<T>({
    required ValueListenable<T> listenable,
    required bool Function(T value) predicate,
    required Duration timeout,
    required String timeoutMessage,
  }) {
    if (predicate(listenable.value)) return Future.value();

    final completer = Completer<void>();
    late final VoidCallback listener;
    Timer? timer;

    void cleanup() {
      timer?.cancel();
      listenable.removeListener(listener);
    }

    listener = () {
      if (completer.isCompleted) return;
      if (predicate(listenable.value)) {
        cleanup();
        completer.complete();
      }
    };

    listenable.addListener(listener);

    timer = Timer(timeout, () {
      if (completer.isCompleted) return;
      cleanup();
      completer.completeError(TimeoutException(timeoutMessage));
    });

    return completer.future;
  }
}

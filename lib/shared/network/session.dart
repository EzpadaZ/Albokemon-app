import 'package:albokemon_app/shared/network/client.dart';
import 'package:albokemon_app/shared/network/events.dart';
import 'package:albokemon_app/shared/utils/game_manager.dart';
import 'package:albokemon_app/shared/utils/logger.dart';
import 'package:flutter/foundation.dart';

class Session {
  Session(this.client);

  final SocketClient client;

  final ValueNotifier<Map<String, dynamic>?> me = ValueNotifier(null);

  Function(dynamic)? _onAuthOk;

  void initListeners() {
    // ensure only once
    try {
      _onAuthOk ??= (dynamic data) {
        final payload = (data is List && data.isNotEmpty) ? data.first : data;
        final user = (payload is Map) ? payload["user"] : null;

        if (user is Map) {
          final u = Map<String, dynamic>.from(user);
          me.value = u;
          GameManager.instance.assignedId = u['id'] as String?;
        }
      };


      client.on(SocketEvents.authOk, _onAuthOk!);
    } catch (e) {
      Logger.instance.error("Error on initListeners: ${e.toString()}");
    }
  }

  void login(String name) {
    client.emit(SocketEvents.authLogin, {"name": name});
  }

  void reset() {
    final handler = _onAuthOk;
    if (handler != null) {
      client.off(SocketEvents.authOk, handler);
    }
    _onAuthOk = null;
    me.value = null; // clear user
  }

  void dispose() {
    // only call this when app is shutting down
    reset();
    me.dispose();
  }
}

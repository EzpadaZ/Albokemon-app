import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  SocketClient(this.url);

  final String url;

  IO.Socket? _socket;

  final ValueNotifier<bool> isConnected = ValueNotifier(false);

  IO.Socket get socket {
    final s = _socket;
    if (s == null) {
      throw StateError('Socket not initialized. Call connect() first.');
    }
    return s;
  }

  void connect() {
    if (_socket != null) {
      _socket!.connect();
      return;
    }

    final s = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    s.onConnect((_) => isConnected.value = true);
    s.onDisconnect((_) => isConnected.value = false);

    s.connect();
    _socket = s;
  }

  void disconnect() {
    _socket?.disconnect();
    isConnected.value = false;
  }

  void emit(String event, [dynamic data]) {
    socket.emit(event, data);
  }

  /// Registers an event listener. Keep a reference to the handler if you want to `off`.
  void on(String event, Function(dynamic) handler) {
    socket.on(event, handler);
  }

  /// Unregisters an event listener. If handler is null, removes all listeners for event.
  void off(String event, [Function(dynamic)? handler]) {
    if (handler == null) {
      socket.off(event);
    } else {
      socket.off(event, handler);
    }
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }
}

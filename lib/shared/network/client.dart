import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  SocketClient(this.url);

  final String url;

  IO.Socket? _socket;

  final ValueNotifier<bool> isConnected = ValueNotifier(false);

  // event -> (originalHandler -> wrappedHandler)
  final Map<String, Map<Function(dynamic), dynamic>> _wrappedHandlersByEvent = {};

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

  void on(String event, Function(dynamic) handler) {
    void wrapped(dynamic data) {
      final payload = (data is List && data.isNotEmpty) ? data.first : data;
      handler(payload);
    }

    final map = _wrappedHandlersByEvent.putIfAbsent(event, () => {});
    map[handler] = wrapped;

    socket.on(event, wrapped);
  }

  /// If handler is null, removes all listeners for that event.
  void off(String event, [Function(dynamic)? handler]) {
    if (handler == null) {
      _wrappedHandlersByEvent.remove(event);
      socket.off(event);
      return;
    }

    final wrapped = _wrappedHandlersByEvent[event]?.remove(handler);
    if (_wrappedHandlersByEvent[event]?.isEmpty ?? false) {
      _wrappedHandlersByEvent.remove(event);
    }

    socket.off(event, wrapped ?? handler);
  }

  void dispose() {
    _wrappedHandlersByEvent.clear();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }
}
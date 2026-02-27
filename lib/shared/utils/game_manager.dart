import 'package:albokemon_app/shared/network/client.dart';
import 'package:albokemon_app/shared/network/session.dart';

class GameManager {
  GameManager._();

  static final GameManager instance = GameManager._();

  late SocketClient socket;
  late Session session;

  String? assignedId;

  bool _init = false;

  void init() {
    if (_init) return;
    socket = SocketClient("http://192.168.1.64:3000");
    session = Session(socket);
    _init = true;
  }

  void disconnect() {
    session.reset();
    socket.disconnect();
    _init = false;
  }
}

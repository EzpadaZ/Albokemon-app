import 'package:albokemon_app/shared/network/client.dart';
import 'package:albokemon_app/shared/network/session.dart';

class GameManager {
  GameManager._();

  static final GameManager instance = GameManager._();

  late SocketClient socket;
  late Session session;

  String? assignedId;

  bool _init = false;

  double music_volume = 0.2;
  String connectionString = "http://192.168.3.201:3001";

  void init() {
    if (_init) return;
    socket = SocketClient(connectionString);
    session = Session(socket);
    _init = true;
  }

  void disconnect() {
    session.reset();
    socket.disconnect();
    _init = false;
  }
}

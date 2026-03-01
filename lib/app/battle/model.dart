import 'package:albokemon_app/shared/utils/audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../shared/network/events.dart';
import '../../shared/utils/game_manager.dart';

class BattleViewModel extends ChangeNotifier {
  BattleViewModel({required this.matchStart}) {
    _onBattleState = (dynamic data) {
      final payload = _unwrap(data);
      if (payload is! Map) return;

      // payload: { matchId, state, events }
      state = (payload['state'] is Map)
          ? Map<String, dynamic>.from(payload['state'])
          : {};

      events = (payload['events'] is List)
          ? (payload['events'] as List)
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : [];

      notifyListeners();
    };

    final s = GameManager.instance.socket;
    s.on(SocketEvents.battleState, _onBattleState!);

    // Always sync once so we don't miss initial state
    s.emit(SocketEvents.battleSync, {"matchId": matchId});
  }

  final Map<String, dynamic> matchStart;

  Map<String, dynamic> state = {};
  List<Map<String, dynamic>> events = [];

  void Function(dynamic)? _onBattleState;

  String get matchId => matchStart['matchId']?.toString() ?? "";

  String get roomId => matchStart['roomId']?.toString() ?? "";

  String get myId => GameManager.instance.assignedId ?? "";

  Map<String, dynamic> get p1 =>
      Map<String, dynamic>.from(matchStart['p1'] ?? {});

  Map<String, dynamic> get p2 =>
      Map<String, dynamic>.from(matchStart['p2'] ?? {});

  String get opponentId {
    final p1Id = p1['id']?.toString() ?? "";
    final p2Id = p2['id']?.toString() ?? "";
    return myId == p1Id ? p2Id : p1Id;
  }

  bool get isActive => (state['phase']?.toString() ?? "") == "ACTIVE";

  String get turnUserId => state['turnUserId']?.toString() ?? "";

  bool get myTurn => isActive && turnUserId == myId;

  Map<String, dynamic> get myActive {
    final active = state['active'];
    if (active is Map && active[myId] is Map) {
      return Map<String, dynamic>.from(active[myId]);
    }
    return {};
  }

  Map<String, dynamic> get oppActive {
    final active = state['active'];
    final opp = opponentId;
    if (active is Map && active[opp] is Map) {
      return Map<String, dynamic>.from(active[opp]);
    }
    return {};
  }

  int get myHp => int.tryParse(myActive['currentHp']?.toString() ?? "") ?? 0;

  int get oppHp => int.tryParse(oppActive['currentHp']?.toString() ?? "") ?? 0;

  String? get myGifUrl => myActive['sprite']?.toString();

  String? get oppGifUrl => oppActive['sprite']?.toString();

  void attack() {
    if (!myTurn) return;
    HapticFeedback.mediumImpact();
    Audio.instance.playSfx('assets/sfx/button_click.wav');
    GameManager.instance.socket.emit(SocketEvents.battleAttack, {
      "matchId": matchId,
    });
  }

  dynamic _unwrap(dynamic data) =>
      (data is List && data.isNotEmpty) ? data.first : data;

  bool get isFinished => (state['phase']?.toString() ?? "") == "FINISHED";

  String get winnerId => state['winnerId']?.toString() ?? "";

  bool get iWon => isFinished && winnerId.isNotEmpty && winnerId == myId;

  String get opponentName {
    final p1m = Map<String, dynamic>.from(matchStart['p1'] ?? {});
    final p2m = Map<String, dynamic>.from(matchStart['p2'] ?? {});
    return (p1m['id']?.toString() == myId)
        ? (p2m['name']?.toString() ?? "Opponent")
        : (p1m['name']?.toString() ?? "Opponent");
  }

  int pokemonsLeft(String playerId) {
    final players = state['players'];
    if (players is! Map) return 0;

    final p = players[playerId];
    if (p is! Map) return 0;

    final team = p['team'];
    final activeIndex = int.tryParse(p['activeIndex']?.toString() ?? '') ?? 0;

    final total = (team is List) ? team.length : 0;
    final left = total - activeIndex; // includes current
    return left < 0 ? 0 : left;
  }

  int get oppLivesLeft {
    return pokemonsLeft(opponentId);
  }

  int get myLivesLeft {
    return pokemonsLeft(myId);
  }

  @override
  void dispose() {
    final s = GameManager.instance.socket;
    if (_onBattleState != null) {
      s.off(SocketEvents.battleState, _onBattleState!);
    }
    super.dispose();
  }
}

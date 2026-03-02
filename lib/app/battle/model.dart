import 'package:albokemon_app/shared/utils/audio.dart';
import 'package:albokemon_app/shared/utils/locale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/network/events.dart';
import '../../shared/utils/game_manager.dart';
import '../../shared/utils/nav.dart';

class BattleViewModel extends ChangeNotifier {
  BattleViewModel({required this.matchStart}) {
    _onBattleState = (dynamic data) {
      if (data is! Map) return;
      final payload = data;

      var prevState = state; // snapshot BEFORE update

      var newState = (payload['state'] is Map)
          ? Map<String, dynamic>.from(payload['state'])
          : <String, dynamic>{};

      var delta = (payload['events'] is List)
          ? (payload['events'] as List)
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : <Map<String, dynamic>>[];

      // append-only logs (use i18n via navigator context)
      final ctx = Nav.routeObserver.navigator?.context;
      if (ctx != null) {
        for (var e in delta) {
          var type = e['type']?.toString() ?? '';

          if (type == 'hit') {
            var fromId = e['from']?.toString() ?? '';
            var toId = e['to']?.toString() ?? '';

            var prevActive = (prevState['active'] is Map)
                ? Map<String, dynamic>.from(prevState['active'])
                : <String, dynamic>{};

            var fromActive = (prevActive[fromId] is Map)
                ? Map<String, dynamic>.from(prevActive[fromId])
                : <String, dynamic>{};

            var toActive = (prevActive[toId] is Map)
                ? Map<String, dynamic>.from(prevActive[toId])
                : <String, dynamic>{};

            logLines.add(
              ctx.i18n.battle_logs_attack
                  .replaceAll('%p', (fromActive['name'] ?? '-').toString())
                  .replaceAll('%a', (toActive['name'] ?? '-').toString())
                  .replaceAll('%n', (e['damage'] ?? 0).toString()),
            );
          }

          if (type == 'ko' || type == 'faint') {
            var whoId = e['who']?.toString() ?? e['to']?.toString() ?? '';

            var prevActive = (prevState['active'] is Map)
                ? Map<String, dynamic>.from(prevState['active'])
                : <String, dynamic>{};

            var whoActive = (prevActive[whoId] is Map)
                ? Map<String, dynamic>.from(prevActive[whoId])
                : <String, dynamic>{};

            logLines.add(
              ctx.i18n.battle_logs_faint.replaceAll(
                '%p',
                (whoActive['name'] ?? '-').toString(),
              ),
            );
          }

          if (type == 'switch' || type == 'new_entry') {
            var whoId = e['who']?.toString() ?? e['playerId']?.toString() ?? '';

            var newActive = (newState['active'] is Map)
                ? Map<String, dynamic>.from(newState['active'])
                : <String, dynamic>{};

            var whoActive = (newActive[whoId] is Map)
                ? Map<String, dynamic>.from(newActive[whoId])
                : <String, dynamic>{};

            logLines.add(
              ctx.i18n.battle_logs_new_entry.replaceAll(
                '%p',
                (whoActive['name'] ?? '-').toString(),
              ),
            );
          }

          if (type == 'win') {
            var winnerId = e['winnerId']?.toString();
            logLines.add(
              (winnerId == myId)
                  ? ctx.i18n.battle_logs_win.replaceAll('%p', opponentName)
                  : ctx.i18n.battle_logs_defeat.replaceAll('%p', opponentName),
            );
          }
        }
      }

      // now apply update
      state = newState;
      events = delta;

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
  List<String> logLines = [];

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

  int get oppMaxHp =>
      int.tryParse(oppActive['maxHp']?.toString() ?? '') ??
      int.tryParse(oppActive['hp']?.toString() ?? '') ??
      0;

  int get myMaxHp =>
      int.tryParse(myActive['maxHp']?.toString() ?? '') ??
      int.tryParse(myActive['hp']?.toString() ?? '') ??
      0;

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

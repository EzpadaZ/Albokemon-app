import 'package:albokemon_app/shared/network/events.dart';
import 'package:albokemon_app/shared/utils/game_manager.dart';
import 'package:albokemon_app/shared/utils/logger.dart';
import 'package:flutter/material.dart';

class LobbyViewModel extends ChangeNotifier {
  void Function(dynamic)? _onUsers;
  void Function(dynamic)? _onUpdated;

  void Function(dynamic)? _onMatchInvite;
  void Function(dynamic)? _onMatchStart;
  void Function(dynamic)? _onMatchDeclined;
  void Function(dynamic)? _onErr;

  Map<String, dynamic> pendingInvite = {}; // {fromUserId, fromName}
  Map<String, dynamic> matchStart = {}; // {matchId, roomId, p1, p2}
  List<String> sentInvites = [];

  List<Map<String, dynamic>> users = [];
  String? error;

  bool _inviteActionInFlight = false;

  LobbyViewModel() {
    _onUsers = (dynamic data) {
      var payload = _unwrap(data);
      final list = (payload is Map) ? payload['users'] : null;

      if (list is List) {
        users = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        notifyListeners();
      }
    };

    _onMatchDeclined = (dynamic data) {
      final payload = _unwrap(data);
      if (payload is! Map) return;

      final reason = payload["reason"]?.toString();

      Logger.instance.info('Match declined: $reason');

      // if you were showing an invite modal, close/clear it
      pendingInvite = {};
      sentInvites.removeLast();
      notifyListeners();
    };

    _onMatchInvite = (dynamic data) {
      final payload = _unwrap(data);
      if (payload is! Map) return;

      pendingInvite = {
        "fromUserId": payload["fromUserId"],
        "fromName": payload["fromName"],
      };
      notifyListeners();
    };

    // NEW: match start
    _onMatchStart = (dynamic data) {
      final payload = _unwrap(data);
      if (payload is! Map) return;

      matchStart = Map<String, dynamic>.from(payload);
      notifyListeners();
    };

    // NEW: error channel
    _onErr = (dynamic data) {
      final payload = _unwrap(data);
      error = payload is Map
          ? (payload["msg"]?.toString() ?? payload.toString())
          : payload.toString();
      notifyListeners();
    };

    _onUpdated = _onUsers;
    GameManager.instance.socket.on(SocketEvents.lobbyUsers, _onUsers!);
    GameManager.instance.socket.on(SocketEvents.lobbyUpdated, _onUpdated!);
    GameManager.instance.socket.on(SocketEvents.matchInvite, _onMatchInvite!);
    GameManager.instance.socket.on(SocketEvents.matchStart, _onMatchStart!);
    GameManager.instance.socket.on(
      SocketEvents.matchDeclined,
      _onMatchDeclined!,
    );
    GameManager.instance.socket.on(SocketEvents.err, _onErr!);
  }

  void requestMatch(String targetUserId) {
    try {
      // IMPORTANT: if your backend expects { targetUser } instead, change the key.
      GameManager.instance.socket.emit(SocketEvents.matchRequest, {
        "targetUserId": targetUserId,
      });
      sentInvites.add(targetUserId);
    } catch (e) {
      error = e.toString();
      Logger.instance.error("Match request error: $error");
      notifyListeners();
    }
  }

  void acceptInvite() {
    if (_inviteActionInFlight) return;

    final inv = pendingInvite;
    if (inv.isEmpty) return;

    final fromUserId = inv["fromUserId"]?.toString();
    if (fromUserId == null) return;

    _inviteActionInFlight = true;

    pendingInvite = {};
    notifyListeners();

    GameManager.instance.socket.emit(SocketEvents.matchAccept, {
      "fromUserId": fromUserId,
    });

    _inviteActionInFlight = false;
  }

  void declineInvite() {
    if (_inviteActionInFlight) return;

    final inv = pendingInvite;
    if (inv.isEmpty) return;

    final fromUserId = inv["fromUserId"]?.toString();
    if (fromUserId == null) return;

    _inviteActionInFlight = true;

    pendingInvite = {};
    notifyListeners();

    GameManager.instance.socket.emit(SocketEvents.matchDecline, {
      "fromUserId": fromUserId,
    });

    _inviteActionInFlight = false;
  }

  dynamic _unwrap(dynamic data) {
    return (data is List && data.isNotEmpty) ? data.first : data;
  }

  void refresh() {
    try {
      GameManager.instance.socket.emit(SocketEvents.lobbyList);
    } catch (e) {
      error = e.toString();
      Logger.instance.error("Lobby refresh error: $error");
      notifyListeners();
    }
  }

  void dispose() {
    final s = GameManager.instance.socket;
    if (_onUsers != null) s.off(SocketEvents.lobbyUsers, _onUsers!);
    if (_onUpdated != null) s.off(SocketEvents.lobbyUpdated, _onUpdated!);
    if (_onMatchInvite != null)
      s.off(SocketEvents.matchInvite, _onMatchInvite!);
    if (_onMatchStart != null) s.off(SocketEvents.matchStart, _onMatchStart!);
    if (_onMatchDeclined != null)
      s.off(SocketEvents.matchDeclined, _onMatchDeclined!);
    super.dispose();
  }
}

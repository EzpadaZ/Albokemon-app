import 'package:albokemon_app/shared/network/events.dart';
import 'package:albokemon_app/shared/utils/audio.dart';
import 'package:albokemon_app/shared/utils/game_manager.dart';
import 'package:albokemon_app/shared/utils/logger.dart';
import 'package:albokemon_app/shared/utils/nav.dart';
import 'package:albokemon_app/shared/utils/theme.dart';
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
  String? _lastRequestedTargetId;

  bool get isInviteBusy => _inviteActionInFlight;

  LobbyViewModel() {
    _onUsers = (dynamic data) {
      if (data is! Map) return;
      final list = data['users'];
      if (list is List) {
        users = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        notifyListeners();
      }
    };

    _onMatchDeclined = (dynamic data) {
      if (data is! Map) return;

      final byUserId = data["byUserId"]?.toString();
      final reason = data["reason"]?.toString();

      Logger.instance.info('Match declined: $reason');

      pendingInvite = {};

      // ✅ safe: remove the correct entry if present
      if (byUserId != null) {
        sentInvites.remove(byUserId);
      } else if (sentInvites.isNotEmpty) {
        sentInvites.removeLast();
      }

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
      if (data is! Map) return;
      matchStart = Map<String, dynamic>.from(data);

      _inviteActionInFlight = false;
      pendingInvite = {}; // closes modal in your view logic
      notifyListeners();
    };

    _onErr = (dynamic data) {
      if (data is! Map) return;

      final code = data['code']?.toString() ?? '';
      final msg = data['msg']?.toString() ?? 'Error';

      final attempted = _lastRequestedTargetId;

      // ✅ If you tried to send a second invite, undo only that attempted loader
      if (code == 'YOU_BUSY' ||
          code == 'TARGET_BUSY' ||
          code == 'OFFLINE' ||
          code == 'IN_MATCH') {
        if (attempted != null) sentInvites.remove(attempted);
      }

      Nav.messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
          ),
        ),
      );

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
    _lastRequestedTargetId = targetUserId;

    if (!sentInvites.contains(targetUserId)) {
      sentInvites.add(targetUserId); // optimistic UI
      notifyListeners();
    }

    GameManager.instance.socket.emit(SocketEvents.matchRequest, {
      "targetUserId": targetUserId,
    });
  }

  void acceptInvite() {
    if (_inviteActionInFlight) return;

    final inv = pendingInvite;
    if (inv.isEmpty) return;

    final fromUserId = inv["fromUserId"]?.toString();
    if (fromUserId == null) return;

    _inviteActionInFlight = true;

    notifyListeners();

    GameManager.instance.socket.emit(SocketEvents.matchAccept, {
      "fromUserId": fromUserId,
    });
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
      Logger.instance.info("Lobby refresh -> emit lobby/list");
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
    if (_onErr != null) s.off(SocketEvents.err, _onErr!);
    Audio.instance.stop();
    super.dispose();
  }
}

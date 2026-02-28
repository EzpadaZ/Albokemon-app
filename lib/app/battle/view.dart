import 'dart:async';
import 'package:albokemon_app/shared/utils/audio.dart';
import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:albokemon_app/shared/widgets/button.dart';
import 'package:albokemon_app/shared/widgets/sprite.dart';
import 'package:flutter/material.dart';
import '../../shared/network/events.dart';
import '../../shared/utils/game_manager.dart';
import 'model.dart';

class BattleView extends StatefulWidget {
  const BattleView({super.key, required this.matchStart});

  final Map<String, dynamic> matchStart;

  @override
  State<BattleView> createState() => _BattleViewState();
}

class _BattleViewState extends State<BattleView> {
  late BattleViewModel _model;

  bool _flashMy = false;
  bool _flashOpp = false;
  int _lastEventsLen = 0;

  @override
  void initState() {
    super.initState();
    Audio.instance.stop();
    Audio.instance.playLoop('assets/bgm/battle.mp3');
    _model = BattleViewModel(matchStart: widget.matchStart);
    _model.addListener(_onModel);
  }

  void _onModel() {
    if (!mounted) return;

    // trigger simple flash on new hit events
    final ev = _model.events;
    if (ev.length > _lastEventsLen) {
      final newEvents = ev.sublist(_lastEventsLen);
      _lastEventsLen = ev.length;

      for (final e in newEvents) {
        if (e['type'] == 'hit') {
          final to = e['to']?.toString();
          if (to == _model.myId) _pulseMy();
          if (to == _model.opponentId) _pulseOpp();
        }
      }
    }

    setState(() {});
  }

  void _pulseMy() {
    setState(() => _flashMy = true);
    Timer(const Duration(milliseconds: 90), () {
      if (!mounted) return;
      setState(() => _flashMy = false);
    });
  }

  void _pulseOpp() {
    setState(() => _flashOpp = true);
    Timer(const Duration(milliseconds: 90), () {
      if (!mounted) return;
      setState(() => _flashOpp = false);
    });
  }

  @override
  void dispose() {
    _model.removeListener(_onModel);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myGif = _model.myGifUrl;
    final oppGif = _model.oppGifUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Opponent (top-right-ish)
            if (oppGif != null)
              _gifSprite(
                url: oppGif,
                greyedOut: !_model.myTurn,
                // optional
                flash: _flashOpp,
                left: MediaQuery.of(context).size.width * 0.75,
                top: MediaQuery.of(context).size.height * 0.12,
              ),

            Positioned(
              left: MediaQuery.of(context).size.width * 0.6,
              top: MediaQuery.of(context).size.height * 0.07,
              child: Image.asset('assets/image/trainer_front.png'),
            ),

            // Player (bottom-left-ish)
            if (myGif != null)
              _gifSprite(
                url: myGif,
                greyedOut: !_model.myTurn,
                flipX: true,
                // grey your pokemon when it's NOT your turn
                flash: _flashMy,
                left: MediaQuery.of(context).size.width * 0.30,
                top: MediaQuery.of(context).size.height * 0.50,
              ),

            Positioned(
              left: MediaQuery.of(context).size.width * 0.01,
              top: MediaQuery.of(context).size.height * 0.49,
              child: spriteSheetFrameV(image: AssetImage('assets/image/trainer_back.png'),frames: 4, frameWidth: 128, frameHeight: 128 , index: 3),
            ),
            // HUD
            Positioned(
              left: 16,
              bottom: 168,
              child: Text(
                "HP: ${_model.myHp}",
                style: ATheme.textStyle(size: FONT_SIZE.H2),
              ),
            ),
            Positioned(
              right: 16,
              top: 12,
              child: Text(
                "ENEMY HP: ${_model.oppHp}",
                style: ATheme.textStyle(size: FONT_SIZE.H2),
              ),
            ),

            // ATTACK button
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: WidgetButton(
                label: _model.myTurn ? 'ATTACK' : 'WAIT',
                isEnabled: _model.myTurn,
                width: 128,
                height: 42,
                onTap: () {
                  if (_model.myTurn) {
                    _model.attack();
                  }
                },
                colorFill: ATheme.BACKGROUND_COLOR,
                colorBorder: ATheme.TEXT_COLOR,
                colorText: ATheme.TEXT_COLOR,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gifSprite({
    required String url,
    required bool greyedOut,
    required bool flash,
    required double left,
    required double top,
    bool flipX = false,
  }) {
    Widget img = Image.network(url, width: 64, height: 64, fit: BoxFit.contain);

    if (flipX) {
      img = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(-1.0, 1.0),
        child: img,
      );
    }

    if (greyedOut) {
      img = Opacity(
        opacity: 0.65,
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
          child: img,
        ),
      );
    }

    return Positioned(
      left: left,
      top: top,
      child: Stack(
        children: [
          img,
          if (flash)
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.65)),
            ),
        ],
      ),
    );
  }
}

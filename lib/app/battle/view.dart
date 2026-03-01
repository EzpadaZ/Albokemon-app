import 'dart:async';
import 'package:albokemon_app/shared/utils/audio.dart';
import 'package:albokemon_app/shared/utils/nav.dart';
import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:albokemon_app/shared/widgets/button.dart';
import 'package:albokemon_app/shared/widgets/sprite.dart';
import 'package:flutter/material.dart';
import '../../shared/network/events.dart';
import '../../shared/utils/game_manager.dart';
import '../lobby/view.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 64),
            // Enemy Display
            enemyDisplay(),
            const Spacer(),
            // My Display
            myDisplay(),
            _model.isFinished ? resultBox() : actionBox(),
          ],
        ),
      ),
    );
  }

  Widget resultBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.18), // glass
          border: Border.all(color: Colors.black.withOpacity(0.28)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              'YOU ${_model.iWon ? "WIN" : "LOST"}!',
              style: ATheme.textStyle(
                size: FONT_SIZE.H2,
                style: FONT_STYLE.BOLD,
              ),
            ),
            const SizedBox(height: 24),
            WidgetButton(
              label: "BACK TO LOBBY",
              height: 42,
              isEnabled: true,
              onTap: () {
                Audio.instance.stop();
                Nav.navigateAndReplaceAll(view: const LobbyView());
              },
              colorFill: Colors.white,
              colorBorder: ATheme.TEXT_COLOR,
              colorText: ATheme.TEXT_COLOR,
            ),
          ],
        ),
      ),
    );
  }

  Widget actionBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.18), // glass
          border: Border.all(color: Colors.black.withOpacity(0.28)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'POKEMON: ${_model.myActive['name'] ?? '-'}',
                  style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                ),
                const SizedBox(height: 4),
                Text(
                  'POKEMON HP: ${_model.myHp}',
                  style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                ),
                const SizedBox(height: 4),
                Text(
                  'POKEMON LEFT: ${_model.myLivesLeft}',
                  style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                ),
                const SizedBox(height: 4),
                Text(
                  'CURRENT TURN: ${_model.myTurn ? "YOU" : "OPPONENT"}',
                  style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Flexible(
              child: WidgetButton(
                label: _model.myTurn ? 'ATTACK' : "WAITING",
                height: 64,
                width: 128,
                isEnabled: _model.myTurn,
                onTap: () {
                  _model.attack();
                },
                colorFill: Colors.white,
                colorBorder: ATheme.TEXT_COLOR,
                colorText: ATheme.TEXT_COLOR,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget myDisplay() {
    final myGif = _model.myGifUrl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        spriteSheetFrameV(
          image: AssetImage('assets/image/trainer_back.png'),
          frames: 4,
          frameWidth: 128,
          frameHeight: 128,
          index: 3,
        ),

        // Player (bottom-left-ish)
        if (myGif != null)
          Transform.translate(
            offset: const Offset(-20, -30),
            child: _gifSprite(
              url: myGif,
              greyedOut: !_model.myTurn,
              flipX: true,
              flash: _flashMy,
              width: 128,
              height: 128,
            ),
          ),
      ],
    );
  }

  Widget enemyDisplay() {
    final oppGif = _model.oppGifUrl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      // helps keep bottoms aligned
      children: [
        Transform.translate(
          offset: const Offset(30, -20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRAINER: ${_model.opponentName}',
                style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
              ),
              Text(
                'POKEMON:  ${_model.oppActive['name'] ?? '-'}',
                style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
              ),
              Text(
                'POKEMON HP: ${_model.oppHp}',
                style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
              ),
              Text(
                'POKEMON LEFT: ${_model.oppLivesLeft}',
                style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (oppGif != null)
          _gifSprite(url: oppGif, greyedOut: !_model.myTurn, flash: _flashOpp),
        Transform.translate(
          offset: const Offset(0, -40), // move up (tweak this)
          child: Image.asset('assets/image/trainer_front.png', scale: 0.8),
        ),
      ],
    );
  }

  Widget _gifSprite({
    required String url,
    required bool greyedOut,
    required bool flash,
    double width = 80,
    double height = 80,
    bool flipX = false,
  }) {
    Widget img = Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );

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
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.saturation,
          ),
          child: img,
        ),
      );
    }

    return Stack(
      children: [
        img,
        if (flash)
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.65)),
          ),
      ],
    );
  }
}

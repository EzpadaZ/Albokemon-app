import 'dart:async';
import 'dart:ui';
import 'package:albokemon_app/shared/utils/audio.dart';
import 'package:albokemon_app/shared/utils/nav.dart';
import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:albokemon_app/shared/widgets/button.dart';
import 'package:albokemon_app/shared/widgets/sprite.dart';
import 'package:flutter/material.dart';
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
  int _lastTurnProcessed = -1;

  String? _dmgMyText;
  String? _dmgOppText;
  bool _showMyDmg = false;
  bool _showOppDmg = false;

  Timer? _myDmgTimer;
  Timer? _oppDmgTimer;

  @override
  void initState() {
    super.initState();
    Audio.instance.stop();
    Audio.instance.playLoop('assets/bgm/battle.mp3');
    _model = BattleViewModel(matchStart: widget.matchStart);
    _model.addListener(_onModel);
  }

  void _showDmgMy(int dmg) {
    _myDmgTimer?.cancel();
    setState(() {
      _dmgMyText = "-$dmg HP";
      _showMyDmg = true;
    });
    _myDmgTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _showMyDmg = false);
    });
  }

  void _showDmgOpp(int dmg) {
    _oppDmgTimer?.cancel();
    setState(() {
      _dmgOppText = "-$dmg HP";
      _showOppDmg = true;
    });
    _oppDmgTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _showOppDmg = false);
    });
  }

  void _onModel() {
    if (!mounted) return;

    final turn = int.tryParse(_model.state['turn']?.toString() ?? '') ?? -1;

    // Only process battle events once per new turn update
    if (turn != -1 && turn != _lastTurnProcessed) {
      _lastTurnProcessed = turn;

      for (final e in _model.events) {
        if (e['type'] == 'hit') {
          final to = e['to']?.toString();
          final dmg = int.tryParse(e['damage']?.toString() ?? '') ?? 0;

          if (to == _model.myId) {
            _pulseMy();
            _showDmgMy(dmg);
            Audio.instance.playSfx('assets/sfx/self_hurt.wav');
          }
          if (to == _model.opponentId) {
            _pulseOpp();
            _showDmgOpp(dmg);
            Audio.instance.playSfx('assets/sfx/attack_opponent.wav');
          }
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
    _myDmgTimer?.cancel();
    _oppDmgTimer?.cancel();
    _model.removeListener(_onModel);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/image/battle_bg.jpg', fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
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
        ),
      ],
    );
  }

  Widget resultBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            // tinted frosted glass
            color: Colors.white.withOpacity(0.18),
            // tint (change if you want)
            border: Border.all(color: Colors.white.withOpacity(0.22)),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 10),
                color: Colors.black.withOpacity(0.22),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  Widget actionBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.30), // frosted tint
            border: Border.all(color: Colors.white.withOpacity(0.22)),
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
                    'POKEMON: ${(_model.myActive['name'] ?? '-').toString().toUpperCase()}',
                    style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'POKEMON HP: ${_model.myHp}',
                        style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                      ),
                      Image.asset(
                        'assets/image/heart.png',
                        width: 16,
                        height: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'POKEMON LEFT: ',
                        style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                      ),
                      ...List.generate(
                        _model.myLivesLeft,
                        (_) => Image.asset(
                          'assets/image/pokeball.png',
                          width: 22,
                          height: 22,
                          filterQuality: FilterQuality.none, // crisp pixel
                        ),
                      ),
                    ],
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
                  onTap: _model.attack,
                  colorFill: Colors.white,
                  colorBorder: ATheme.TEXT_COLOR,
                  colorText: ATheme.TEXT_COLOR,
                ),
              ),
            ],
          ),
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

        if (myGif != null)
          Transform.translate(
            offset: const Offset(-20, -30),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: (128 - 70) / 2, // center it (tweak)
                  top: 90, // push below (tweak)
                  child: Opacity(
                    opacity: 0.35,
                    child: Container(
                      width: 64,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                _gifSprite(
                  url: myGif,
                  flipX: true,
                  flash: _flashMy,
                  width: 128,
                  height: 128,
                ),

                if (_showMyDmg && _dmgMyText != null)
                  Positioned(
                    right: 20,
                    top: -10,
                    child: _damageTextAnimated(_dmgMyText!),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget enemyDisplay() {
    final oppGif = _model.oppGifUrl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      // helps keep bottoms aligned
      children: [
        Transform.translate(
          offset: const Offset(30, -20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                  color: Colors.black.withOpacity(0.30), // floating shadow
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TRAINER: ${_model.opponentName}',
                        style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                      ),
                      Text(
                        'POKEMON:  ${(_model.oppActive['name'] ?? '-').toString().toUpperCase()}',
                        style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                      ),
                      Row(
                        children: [
                          Text(
                            'POKEMON HP: ${_model.oppHp}',
                            style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                          ),
                          Image.asset(
                            'assets/image/heart.png',
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'POKEMON LEFT: ',
                            style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                          ),
                          ...List.generate(
                            _model.oppLivesLeft,
                            (_) => Image.asset(
                              'assets/image/pokeball.png',
                              width: 22,
                              height: 22,
                              filterQuality: FilterQuality.none, // crisp pixel
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        if (oppGif != null)
          Stack(
            clipBehavior: Clip.none,
            children: [
              // shadow behind + below enemy gif
              Positioned(
                left: (64 - 70) / 2,
                // assumes gif is ~128 wide; tweak if different
                top: 64 - 30,
                child: Opacity(
                  opacity: 0.35,
                  child: Container(
                    width: 70,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              _gifSprite(url: oppGif, flash: _flashOpp, width: 64, height: 64),
              if (_showOppDmg && _dmgOppText != null)
                Positioned(
                  left: -10,
                  top: -20,
                  child: _damageTextAnimated(_dmgOppText!),
                ),
            ],
          ),

        Transform.translate(
          offset: const Offset(0, -40),
          child: Image.asset(
            'assets/image/trainer_front.png',
            scale: 0.8,
            filterQuality: FilterQuality.none,
          ),
        ),
      ],
    );
  }

  Widget _damageTextAnimated(String text) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 650),
      builder: (context, t, child) {
        // t: 0 -> 1
        final dy = lerpDouble(0, -18, t)!; // move up
        final opacity = (1.0 - (t * 0.6)).clamp(0, 1); // fade a bit

        return Opacity(
          opacity: opacity * 1.0,
          child: Transform.translate(offset: Offset(0, dy), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: ATheme.textStyle(
            size: FONT_SIZE.PARAGRAPH,
          ).copyWith(color: ATheme.DAMAGE_COLOR, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _gifSprite({
    required String url,
    bool greyedOut = false,
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
      filterQuality: FilterQuality.none,
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

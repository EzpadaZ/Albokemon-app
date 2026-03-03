import 'dart:ui';

import 'package:albokemon_app/app/battle/view.dart';
import 'package:albokemon_app/app/lobby/model.dart';
import 'package:albokemon_app/app/login/view.dart';
import 'package:albokemon_app/shared/utils/audio.dart';
import 'package:albokemon_app/shared/utils/game_manager.dart';
import 'package:albokemon_app/shared/utils/locale.dart';
import 'package:albokemon_app/shared/utils/logger.dart';
import 'package:albokemon_app/shared/utils/nav.dart';
import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:albokemon_app/shared/widgets/animated/pikachu_running.dart';
import 'package:albokemon_app/shared/widgets/button.dart';
import 'package:albokemon_app/shared/widgets/modal.dart';
import 'package:albokemon_app/shared/widgets/thirdparty/pixel_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LobbyView extends StatefulWidget {
  const LobbyView({super.key});

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  late LobbyViewModel _model;
  bool _isInviteModalDisplayed = false;
  BuildContext? _inviteCtx;

  void _openInviteModal() {
    _isInviteModalDisplayed = true;

    WidgetModalBase().showConfirmationModal(
      dismissable: false,
      context,
      childWidget: Builder(
        builder: (ctx) {
          _inviteCtx = ctx;
          return AnimatedBuilder(
            animation: _model,
            builder: (_, __) => invite(), // rebuilds when _model.notifyListeners()
          );
        },
      ),
    );
  }

  void _closeInviteModal() {
    if (_inviteCtx != null && Navigator.of(_inviteCtx!).canPop()) {
      Navigator.of(_inviteCtx!).pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    _inviteCtx = null;
    _isInviteModalDisplayed = false;
  }

  @override
  void initState() {
    super.initState();
    _model = LobbyViewModel();

    _model.addListener(() {
      if (!mounted) return;
      setState(() {}); // keep simple

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final hasInvite = _model.pendingInvite.isNotEmpty;

        if (hasInvite && !_isInviteModalDisplayed) {
          _openInviteModal();
        } else if (!hasInvite && _isInviteModalDisplayed) {
          _closeInviteModal();
        }

        if (_model.matchStart.isNotEmpty) {
          final ms = _model.matchStart;
          _model.matchStart = {};
          Nav.navigateToWidget(view: BattleView(matchStart: ms));
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _model.refresh(); // ✅ snapshot request when view is mounted
    });

    if (!Audio.instance.isPlaying()) {
      Audio.instance.playLoop('assets/bgm/menu.mp3');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/image/lobby_bg.jpg', fit: BoxFit.cover),
          ),
          Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: Text(
                context.i18n.lobby_title,
                style: ATheme.textStyle(size: FONT_SIZE.H2),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Audio.instance.playSfx('assets/sfx/button_click.wav');
                    Logger.instance.info(
                      "Disconnect Action: ${GameManager.instance.assignedId}",
                    );
                    GameManager.instance.disconnect();
                    Nav.navigateAndReplaceAll(view: const LoginView());
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: PixelBorder.solid(
                        borderRadius: BorderRadius.circular(2.0),
                        pixelSize: 0.5,
                        color: ATheme.FOREGROUND_COLOR,
                      ),
                    ),
                    width: 16,
                    height: 16,
                    child: Center(
                      child: Text(
                        '<',
                        style: ATheme.textStyle(size: FONT_SIZE.H2),
                      ),
                    ),
                  ),
                ),
              ),

              // glass effect
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.22)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(child: lobby()),
                  characterFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget characterFooter() {
    return SizedBox(
      height: 164,
      child: Stack(
        children: [
          Positioned(
            left: 128,
            bottom: 80,
            child: Image.asset(
              'assets/image/snorlax_fight.gif',
              height: 64,
              width: 64,
              filterQuality: FilterQuality.none,
            ),
          ),
          Positioned(
            left: 64,
            bottom: 80,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0), // flip X
              child: Image.asset(
                'assets/image/snorlax_fight.gif',
                height: 64,
                width: 64,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 64,
            child: Image.asset(
              'assets/image/bulbasaur.gif',
              height: 64,
              width: 64,
              filterQuality: FilterQuality.none,
            ),
          ),
          const RunningPikachu(bottom: -64,  size: 64),
        ],
      ),
    );
  }

  Widget invite() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.i18n.lobby_invite_message.replaceAll(
              '%p',
              (_model.pendingInvite['fromName']?.toString() ?? ''),
            ),
            style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
          ),
          const SizedBox(height: 16),
          WidgetButton(
            label: context.i18n.lobby_invite_accept,
            width: 128,
            height: 42,
            isEnabled: !_model.isInviteBusy,
            onTap: () {
              HapticFeedback.mediumImpact();
              Audio.instance.playSfx('assets/sfx/button_click.wav');
              _model.acceptInvite();
            },
            colorFill: ATheme.BACKGROUND_COLOR,
            colorBorder: ATheme.TEXT_COLOR,
            colorText: ATheme.TEXT_COLOR,
          ),
          const SizedBox(height: 8),
          WidgetButton(
            label: context.i18n.lobby_invite_reject,
            width: 128,
            height: 42,
            isEnabled: !_model.isInviteBusy,
            onTap: () {
              HapticFeedback.mediumImpact();
              Audio.instance.playSfx('assets/sfx/button_click.wav');
              _model.declineInvite();
            },
            colorFill: ATheme.BACKGROUND_COLOR,
            colorBorder: ATheme.TEXT_COLOR,
            colorText: ATheme.TEXT_COLOR,
          ),
        ],
      ),
    );
  }

  Widget lobby() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.28)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                  color: Colors.black.withOpacity(0.18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    context.i18n.lobby_online_tag.replaceAll(
                      '%p',
                      _model.users.length.toString(),
                    ),
                    textAlign: TextAlign.left,
                    style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                  ),
                ),
                Expanded(child: userList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget userList() {
    return ListView.builder(
      itemCount: _model.users.length,
      itemBuilder: (context, index) {
        return userField(_model.users[index]);
      },
    );
  }

  Widget userField(Map<String, dynamic> info) {
    bool self = info['id'] == GameManager.instance.assignedId;
    if (self) return Container();
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: PixelBorder.solid(
            borderRadius: BorderRadius.circular(2.0),
            pixelSize: 0.5,
            color: ATheme.FOREGROUND_COLOR,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              info['name'],
              style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
            ),
            self
                ? Container()
                : _model.sentInvites.contains(info['id'])
                ? LoadingAnimationWidget.waveDots(
                    color: ATheme.TEXT_COLOR,
                    size: 42.0,
                  )
                : WidgetButton(
                    label: context.i18n.lobby_battle_button,
                    width: 128,
                    height: 42,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Audio.instance.playSfx('assets/sfx/button_click.wav');
                      setState(() {
                        _model.requestMatch(info['id']);
                      });
                    },
                    colorFill: ATheme.BACKGROUND_COLOR,
                    colorBorder: ATheme.TEXT_COLOR,
                    colorText: ATheme.TEXT_COLOR,
                  ),
          ],
        ),
      ),
    );
  }
}

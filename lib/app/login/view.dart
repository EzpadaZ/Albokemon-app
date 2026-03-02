import 'dart:ui';

import 'package:albokemon_app/shared/utils/audio.dart';
import 'package:albokemon_app/shared/utils/game_manager.dart';
import 'package:albokemon_app/shared/utils/logger.dart';
import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:albokemon_app/shared/widgets/text_field.dart';
import 'package:albokemon_app/shared/widgets/text_pulse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../shared/utils/locale.dart';
import '../../shared/utils/nav.dart';
import 'model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late LoginViewModel _model;
  bool showTextfield = false;
  bool showSettings = false;

  String editedConnection = "";
  String username = "";

  @override
  void initState() {
    _model = LoginViewModel();
    Audio.instance.playLoop('assets/bgm/menu.mp3');
    editedConnection = GameManager.instance.connectionString;
    username = _model.username;

    Logger.instance.info("Conn:: $editedConnection");
    _model.addListener(() {
      setState(() {}); // allows the model to update the view.
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ATheme.BACKGROUND_COLOR,
      body: SafeArea(
        child: _model.isLoading
            ? loading()
            : Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/image/main_bg.jpg',
                      fit: BoxFit.cover, // usually better than fill
                    ),
                  ),
                  Positioned(
                    bottom: 216,
                    left: MediaQuery.of(context).size.width * 0.5,
                    child: Image.asset(
                      'assets/image/snorlax_sleeping.gif',
                      width: 128,
                      height: 128,
                    ),
                  ),
                  body(),
                ],
              ),
      ),
    );
  }

  Widget loading() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.fourRotatingDots(
            color: ATheme.TEXT_COLOR,
            size: 128.0,
          ),
          const SizedBox(height: 24),
          Text(
            _model.isConnected
                ? context.i18n.login_auth_con
                : context.i18n.login_server_con,
            textAlign: TextAlign.center,
            style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 64),
          SizedBox(height: 76, child: Image.asset('assets/image/logo.png')),
          const SizedBox(height: 8),
          Text(
            context.i18n.login_logo_desc,
            textAlign: TextAlign.center,
            style: ATheme.textStyle(
              size: FONT_SIZE.SMALL,
              family: FONT_FAMILY.FIPPS,
            ),
          ),
          const SizedBox(height: 64),
          animatedTextfield(),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 220, // pick a value that fits your longest label
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      Audio.instance.playSfx('assets/sfx/button_click.wav');
                      if (showTextfield && _model.username.isNotEmpty) {
                        await _model.execute();
                      } else {
                        setState(() {
                          showTextfield = !showTextfield;

                          if (showSettings) {
                            showSettings = false;
                          }
                        });
                      }
                    },
                    child: SmoothColorText(
                      context.i18n.login_play,
                      colorA: ATheme.LIGHT_DARK_GREEN,
                      colorB: ATheme.DARK_GREEN,
                      glass: false,
                      style: ATheme.textStyle(
                        size: FONT_SIZE.H2,
                        style: FONT_STYLE.BOLD,
                        family: FONT_FAMILY.FIPPS,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      Audio.instance.playSfx('assets/sfx/button_click.wav');
                      setState(() {
                        showSettings = !showSettings;
                      });
                    },
                    child: SmoothColorText(
                      context.i18n.login_settings,
                      colorA: ATheme.LIGHT_DARK_GREEN,
                      colorB: ATheme.DARK_GREEN,
                      glass: false,
                      style: ATheme.textStyle(
                        size: FONT_SIZE.H2,
                        style: FONT_STYLE.BOLD,
                        family: FONT_FAMILY.FIPPS,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            context.i18n.login_footer,
            style: ATheme.textStyle(size: FONT_SIZE.H4, style: FONT_STYLE.BOLD),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget animatedTextfield() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => SizeTransition(
        sizeFactor: anim,
        axisAlignment: -1, // expand from top
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: showSettings
          ? settingsBox()
          : showTextfield
          ? textfield()
          : const SizedBox(key: ValueKey('empty')),
    );
  }

  Widget settingsBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0x10000000), // semi-transparent
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.i18n.settings_title,
                style: ATheme.textStyle(
                  size: FONT_SIZE.H4,
                  style: FONT_STYLE.BOLD,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                     context.i18n.settings_language,
                    style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          GameManager.instance.prevLocale(context);
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '<',
                              style: ATheme.textStyle(
                                size: FONT_SIZE.PARAGRAPH,
                                style: FONT_STYLE.BOLD,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        GameManager.instance.localeLabel(context),
                        style: ATheme.textStyle(
                          size: FONT_SIZE.PARAGRAPH,
                          style: FONT_STYLE.BOLD,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          GameManager.instance.nextLocale(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '>',
                            style: ATheme.textStyle(
                              size: FONT_SIZE.PARAGRAPH,
                              style: FONT_STYLE.BOLD,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Volumen',
                    style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (GameManager.instance.music_volume > 0.0) {
                            setState(() {
                              GameManager.instance.music_volume -= 0.05;
                              Audio.instance.updateVolume();
                            });
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '-',
                              style: ATheme.textStyle(
                                size: FONT_SIZE.PARAGRAPH,
                                style: FONT_STYLE.BOLD,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        (GameManager.instance.music_volume * 100)
                            .toStringAsFixed(1),
                        style: ATheme.textStyle(
                          size: FONT_SIZE.PARAGRAPH,
                          style: FONT_STYLE.BOLD,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          if (GameManager.instance.music_volume > 0.0) {
                            setState(() {
                              GameManager.instance.music_volume += 0.05;
                              Audio.instance.updateVolume();
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '+',
                            style: ATheme.textStyle(
                              size: FONT_SIZE.PARAGRAPH,
                              style: FONT_STYLE.BOLD,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.i18n.settings_server_address,
                    style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
                  ),
                  WidgetTextField(
                    value: editedConnection,
                    initialValue: editedConnection,
                    hintText: "http://localhost:3001",
                    onChange: (p) {
                      GameManager.instance.connectionString = p;
                      editedConnection = p;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textfield() {
    return Column(
      children: [
        WidgetTextField(
          value: _model.username.isNotEmpty ? _model.username : username,
          hintText: context.i18n.login_textfield_hint,
          maxLength: 8,
          initialValue: username,
          onChange: (v) {
            setState(() {
              _model.username = v;
              username = v;
            });
          },
        ),
        const SizedBox(height: 8),
        _model.error != null
            ? _model.error!.isNotEmpty
                  ? Text(
                      _model.error ?? "Error Generico",
                      style: ATheme.textStyle(
                        size: FONT_SIZE.SMALL,
                        color: ATheme.DAMAGE_COLOR,
                      ),
                    )
                  : Container()
            : Container(),
      ],
    );
  }
}

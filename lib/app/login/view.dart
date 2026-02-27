import 'package:albokemon_app/shared/utils/logger.dart';
import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:albokemon_app/shared/widgets/button.dart';
import 'package:albokemon_app/shared/widgets/text_field.dart';
import 'package:albokemon_app/shared/widgets/thirdparty/pixel_border.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late LoginViewModel _model;

  @override
  void initState() {
    // TODO: implement initState
    _model = new LoginViewModel();
    _model.addListener(() {
      setState(() {}); // allows the model to update the view.
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATheme.BACKGROUND_COLOR,
      body: SafeArea(child: _model.isLoading ? loading() : body()),
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
            _model.isConnected ? "Haciendo Login!" : "Conectando al servidor",
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
          const SizedBox(height: 16),
          Text(
            'Bienvenido a Albokémon\nProyecto para la prueba tecnica de \nSr. Software Engineer de Albo',
            style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          WidgetTextField(
            value: _model.username,
            hintText: "Introduce tu nombre de jugador",
            maxLength: 8,
            onChange: (v) {
              setState(() {
                _model.username = v;
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
          const Spacer(),
          WidgetButton(
            label: 'Jugar',
            height: 48,
            onTap: () async {
              Logger.instance.info("Content: ${_model.username}");
              await _model.execute();
            },
            colorFill: ATheme.BACKGROUND_COLOR,
            colorBorder: ATheme.TEXT_COLOR,
            colorText: ATheme.TEXT_COLOR,
          ),
        ],
      ),
    );
  }
}

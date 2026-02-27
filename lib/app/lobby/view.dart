import 'package:albokemon_app/app/lobby/model.dart';
import 'package:albokemon_app/app/login/view.dart';
import 'package:albokemon_app/shared/utils/game_manager.dart';
import 'package:albokemon_app/shared/utils/logger.dart';
import 'package:albokemon_app/shared/utils/nav.dart';
import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:albokemon_app/shared/widgets/button.dart';
import 'package:albokemon_app/shared/widgets/modal.dart';
import 'package:albokemon_app/shared/widgets/thirdparty/pixel_border.dart';
import 'package:flutter/material.dart';
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
          _inviteCtx = ctx; // context inside the dialog
          return invite();
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
    _model = new LobbyViewModel();
    _model.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final hasInvite = _model.pendingInvite.isNotEmpty;

        if (hasInvite && !_isInviteModalDisplayed) {
          _openInviteModal();
        } else if (!hasInvite && _isInviteModalDisplayed) {
          _closeInviteModal();
        }
      });

      if (mounted) setState(() {});
    });
    _model.refresh();
    super.initState();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby', style: ATheme.textStyle(size: FONT_SIZE.H2)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
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
                child: Text('<', style: ATheme.textStyle(size: FONT_SIZE.H2)),
              ),
            ),
          ),
        ),
        backgroundColor: ATheme.BACKGROUND_COLOR,
      ),
      backgroundColor: ATheme.BACKGROUND_COLOR,
      body: SafeArea(child: lobby()),
    );
  }

  Widget invite() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [Text('You received an invite')]),
    );
  }

  Widget lobby() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              "Users Online: ${_model.users.length} (including self)",
              textAlign: TextAlign.left,
              style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
            ),
          ),
          Expanded(child: userList()),
        ],
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
                    label: 'Battle',
                    width: 128,
                    height: 42,
                    onTap: () {
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

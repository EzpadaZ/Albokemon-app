import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:flutter/material.dart';

class WidgetModalBase {
  void showConfirmationModal(BuildContext context,
      {required childWidget,
        heightPercentage = 80,
        dismissable = true,
        fullScreen = false,
        scrollControlled = true,
        borderRadius = 10.0}) {
    showModalBottomSheet(
        backgroundColor: ATheme.BACKGROUND_COLOR,
        context: context,
        constraints: (fullScreen)
            ? BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (95 / 100),
        )
            : null,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius)),
        isScrollControlled: scrollControlled,
        isDismissible: dismissable,
        enableDrag: dismissable,
        builder: (BuildContext bc) {
          // return Flex(direction: Axis.vertical, children: [
          //   Flexible(child: childWidget),
          // ]);
          return (fullScreen)
              ? SafeArea(child: childWidget)
              : SafeArea(
            child: SingleChildScrollView(
                child: Container(
                  padding: (fullScreen)
                      ? null
                      : EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: childWidget,
                )),
          );
        });
  }
}

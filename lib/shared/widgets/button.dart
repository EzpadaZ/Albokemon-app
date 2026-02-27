import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:albokemon_app/shared/widgets/thirdparty/pixel_border.dart';
import 'package:flutter/material.dart';

class WidgetButton extends StatelessWidget {
  final String label;
  final Function() onTap;

  final Color colorFill;
  final Color colorBorder;
  final Color colorText;

  final Color colorDisabledFill;
  final Color colorDisabledBorder;
  final Color colorDisabledText;

  final bool isEnabled;
  final double? width;
  final double? height;
  final double borderWidth = 1.0;

  final EdgeInsetsGeometry? padding;

  final double borderRadius;
  final double elevation = 0.0;

  final TextStyle? textStyle;
  final TextStyle? textStyleDisabled;

  const WidgetButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.colorFill,
    required this.colorBorder,
    required this.colorText,
    this.colorDisabledFill = ATheme.DISABLED_COLOR,
    this.colorDisabledBorder = ATheme.DISABLED_COLOR,
    this.colorDisabledText = ATheme.FOREGROUND_COLOR,
    this.isEnabled = true,
    this.padding,
    this.width,
    this.height,
    this.textStyle,
    this.textStyleDisabled,
    this.borderRadius = 4.0,
  });

  TextStyle getTextStyle() {
    if (textStyle != null) {
      return textStyle!;
    }

    return ATheme.textStyle(
      size: FONT_SIZE.H4,
      style: FONT_STYLE.BOLD,
      color: colorText,
    );
  }

  TextStyle getTextStyleDisabled() {
    if (textStyleDisabled != null) {
      return textStyleDisabled!;
    }

    return ATheme.textStyle(
      size: FONT_SIZE.H4,
      style: FONT_STYLE.BOLD,
      color: colorDisabledText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isEnabled) ? onTap : null,
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(
              borderRadius,
            ),
          ),
          border: Border.all(
            color: isEnabled ? colorBorder : colorDisabledBorder,
            width: borderWidth,
          ),
          color: isEnabled ? colorFill : colorDisabledFill,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: isEnabled ? getTextStyle() : getTextStyleDisabled(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
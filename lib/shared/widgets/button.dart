import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WidgetButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  final Color colorFill;
  final Color colorBorder;
  final Color colorText;

  final Color colorDisabledFill;
  final Color colorDisabledBorder;
  final Color colorDisabledText;

  final bool isEnabled;
  final double? width;
  final double? height;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;

  final double borderRadius;

  final TextStyle? textStyle;
  final TextStyle? textStyleDisabled;

  // new
  final double lift; // how "raised" it is
  final Color shadowColor;

  const WidgetButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.colorFill,
    required this.colorBorder,
    required this.colorText,
    this.colorDisabledFill = ATheme.DISABLED_COLOR,
    this.colorDisabledBorder = ATheme.DISABLED_COLOR,
    this.colorDisabledText = ATheme.TEXT_HINT,
    this.isEnabled = true,
    this.padding,
    this.width,
    this.height,
    this.textStyle,
    this.textStyleDisabled,
    this.borderRadius = 4.0,
    this.borderWidth = 1.0,
    this.lift = 4.0,
    this.shadowColor = const Color(0xAA000000),
  });

  @override
  State<WidgetButton> createState() => _WidgetButtonState();
}

class _WidgetButtonState extends State<WidgetButton> {
  bool _pressed = false;

  TextStyle _getTextStyle() {
    if (widget.textStyle != null) return widget.textStyle!;
    return ATheme.textStyle(
      size: FONT_SIZE.H4,
      style: FONT_STYLE.BOLD,
      color: widget.colorText,
    );
  }

  TextStyle _getTextStyleDisabled() {
    if (widget.textStyleDisabled != null) return widget.textStyleDisabled!;
    return ATheme.textStyle(
      size: FONT_SIZE.H4,
      style: FONT_STYLE.BOLD,
      color: widget.colorDisabledText,
    );
  }

  void _setPressed(bool v) {
    if (!widget.isEnabled) return;
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled;

    final fill = enabled ? widget.colorFill : widget.colorDisabledFill;
    final border = enabled ? widget.colorBorder : widget.colorDisabledBorder;
    final textStyle = enabled ? _getTextStyle() : _getTextStyleDisabled();

    final lift = enabled ? widget.lift : 0.0;
    final y = _pressed ? lift : 0.0; // move down when pressed -> flat

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: enabled
          ? () {
        HapticFeedback.selectionClick();
        widget.onTap();
      }
          : null,
      child: SizedBox(
        width: widget.width,
        height: widget.height != null ? widget.height! + lift : null,
        child: Stack(
          children: [
            // shadow "base"
            Positioned(
              left: 0,
              right: 0,
              top: lift,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  color: widget.shadowColor,
                ),
              ),
            ),

            // face (moves down on press)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 70),
              curve: Curves.linear,
              left: 0,
              right: 0,
              top: y,
              child: Container(
                height: widget.height,
                padding: widget.padding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(color: border, width: widget.borderWidth),
                  color: fill,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
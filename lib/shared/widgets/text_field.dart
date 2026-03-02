import 'package:albokemon_app/shared/utils/theme.dart';
import 'package:albokemon_app/shared/widgets/thirdparty/pixel_border.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class WidgetTextField extends StatefulWidget {
  void Function(String) onChange;
  Function()? onTap;
  String value;
  int? maxLength;
  String? hintText;
  String? initialValue;

  WidgetTextField({
    required this.value,
    required this.onChange,
    this.onTap,
    this.maxLength,
    this.hintText,
    this.initialValue,
    super.key,
  });

  @override
  State<WidgetTextField> createState() => _WidgetTextFieldState();
}

class _WidgetTextFieldState extends State<WidgetTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: ATheme.BACKGROUND_COLOR,
        shape: PixelBorder.solid(
          borderRadius: BorderRadius.circular(2.0),
          pixelSize: 0.5,
          color: ATheme.FOREGROUND_COLOR,
        ),
      ),
      child: TextFormField(
        cursorWidth: 1.0,
        cursorHeight: 12,
        cursorColor: ATheme.TEXT_COLOR,
        style: ATheme.textStyle(size: FONT_SIZE.PARAGRAPH),
        keyboardType: TextInputType.text,
        initialValue: widget.initialValue,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(8),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: ATheme.textStyle(
            size: FONT_SIZE.PARAGRAPH,
            color: ATheme.TEXT_HINT,
          ),
          border: InputBorder.none,
          isDense: true,
          counterText: "",
          counter: null,
        ),
        maxLength: widget.maxLength,
        onChanged: (value) {
          widget.onChange(value);
          return;
        },
      ),
    );
  }
}

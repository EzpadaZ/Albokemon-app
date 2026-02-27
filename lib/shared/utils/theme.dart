import 'package:flutter/material.dart';

enum FONT_SIZE {
  H0,
  H1,
  H2,
  H3,
  H4,
  PARAGRAPH,
  SMALL,
  TINY,
}

enum FONT_STYLE {
  REGULAR,
  BOLD,
  SEMIBOLD
}

enum FONT_DECORATION {
  UNDERLINE,
  LINE_THROUGH,
  OVERLINE,
  NONE,
}

enum FONT_FAMILY { MONOCRAFT }

class ATheme {
  static const Color BACKGROUND_COLOR = Color(0xFFF7F4E9);
  static const Color FOREGROUND_COLOR = Color(0xFF1F1F1F);
  static const Color TEXT_COLOR = Color(0xFF111111);
  static const Color DISABLED_COLOR = Color(0xFFEDF0F4);
  static const Color TEXT_HINT = Color(0xFF7F8081);
  static const Color DAMAGE_COLOR = Color(0xFFD64B3C);
  static const Color WARNING_COLOR = Color(0xFFE0B12D);

  static const double _FONT_SIZE_H0 = 32.0;
  static const double _FONT_SIZE_H1 = 32.0;
  static const double _FONT_SIZE_H2 = 24.0;
  static const double _FONT_SIZE_H3 = 18.0;
  static const double _FONT_SIZE_H4 = 16.0;
  static const double _FONT_SIZE_PARAGRAPH = 14.0;
  static const double _FONT_SIZE_SMALL = 12.0;
  static const double _FONT_SIZE_TINY = 10.0;

  static const double _FONT_LETTER_SPACE_H1 = -1.0;
  static const double _FONT_LETTER_SPACE_H2 = -0.24;
  static const double _FONT_LETTER_SPACE_H3 = -0.09;
  static const double _FONT_LETTER_SPACE_H4 = -0.06;
  static const double _FONT_LETTER_SPACE_PARAGRAPH = -0.07;
  static const double _FONT_LETTER_SPACE_SMALL = -0.06;
  static const double _FONT_LETTER_SPACE_TINY = -0.5;

  static TextStyle textStyle({
    required FONT_SIZE size,
    Color color = TEXT_COLOR,
    FONT_STYLE style = FONT_STYLE.REGULAR,
    FONT_DECORATION decoration = FONT_DECORATION.NONE,
    FONT_FAMILY family = FONT_FAMILY.MONOCRAFT,
  }) {
    double fontSize, fontLetterSpace;
    switch (size) {
      case FONT_SIZE.H0:
        fontSize = _FONT_SIZE_H0;
        fontLetterSpace = _FONT_LETTER_SPACE_H1;
        break;
      case FONT_SIZE.H1:
        fontSize = _FONT_SIZE_H1;
        fontLetterSpace = _FONT_LETTER_SPACE_H1;
        break;
      case FONT_SIZE.H2:
        fontSize = _FONT_SIZE_H2;
        fontLetterSpace = _FONT_LETTER_SPACE_H2;
        break;
      case FONT_SIZE.H3:
        fontSize = _FONT_SIZE_H3;
        fontLetterSpace = _FONT_LETTER_SPACE_H3;
        break;
      case FONT_SIZE.H4:
        fontSize = _FONT_SIZE_H4;
        fontLetterSpace = _FONT_LETTER_SPACE_H4;
        break;
      case FONT_SIZE.PARAGRAPH:
        fontSize = _FONT_SIZE_PARAGRAPH;
        fontLetterSpace = _FONT_LETTER_SPACE_PARAGRAPH;
        break;
      case FONT_SIZE.SMALL:
        fontSize = _FONT_SIZE_SMALL;
        fontLetterSpace = _FONT_LETTER_SPACE_SMALL;
        break;
      case FONT_SIZE.TINY:
        fontSize = _FONT_SIZE_TINY;
        fontLetterSpace = _FONT_LETTER_SPACE_TINY;
        break;
    }

    FontWeight fontWeight;
    switch (style) {
      case FONT_STYLE.REGULAR:
        fontWeight = FontWeight.w400;
        break;
      case FONT_STYLE.BOLD:
        fontWeight = FontWeight.w700;
        break;
      case FONT_STYLE.SEMIBOLD:
        fontWeight = FontWeight.w600;
        break;
    }

    String fontFamily;
    switch (family) {
      case FONT_FAMILY.MONOCRAFT:
        fontFamily = "Monocraft";
        break;
    }

    TextDecoration textDecoration;
    switch (decoration) {
      case FONT_DECORATION.NONE:
        textDecoration = TextDecoration.none;
        break;
      case FONT_DECORATION.UNDERLINE:
        textDecoration = TextDecoration.underline;
        break;
      case FONT_DECORATION.LINE_THROUGH:
        textDecoration = TextDecoration.lineThrough;
        break;
      case FONT_DECORATION.OVERLINE:
        textDecoration = TextDecoration.overline;
        break;
    }

    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      decoration: textDecoration,
      color: color,
      fontSize: fontSize,
      letterSpacing: fontLetterSpace,
    );
  }
}
import 'package:flutter/material.dart';

Widget spriteSheetFrameV({
  required ImageProvider image,
  required int frames,        // 4
  required int index,         // 0..frames-1
  required double frameWidth,
  required double frameHeight,
}) {
  final sheetHeight = frameHeight * frames;
  final dy = -frameHeight * index;

  return SizedBox(
    width: frameWidth,
    height: frameHeight,
    child: ClipRect(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: frameWidth,
        maxWidth: frameWidth,
        minHeight: sheetHeight,
        maxHeight: sheetHeight,
        child: Transform.translate(
          offset: Offset(0, dy),
          child: SizedBox(
            width: frameWidth,
            height: sheetHeight,
            child: Image(
              image: image,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget spriteSheetLastFrame4({
  required ImageProvider image,
  required double width,
  required double height,
}) {
  return spriteSheetFrameV(
    image: image,
    frames: 4,
    index: 3,
    frameWidth: width,
    frameHeight: height,
  );
}
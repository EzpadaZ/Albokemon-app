import 'dart:ui';
import 'package:flutter/material.dart';

class RunningPikachu extends StatefulWidget {
  const RunningPikachu({
    super.key,
    this.bottom,
    this.size = 64,
    this.startLeft = -64,
    this.top,
    this.duration = const Duration(seconds: 3),
  });

  final double? bottom;
  final double size;
  final double startLeft; // negative = start hidden on left
  final Duration duration;
  final double? top;

  @override
  State<RunningPikachu> createState() => _RunningPikachuState();
}

class _RunningPikachuState extends State<RunningPikachu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final endLeft = screenW + 10; // go a bit beyond right edge

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final left = lerpDouble(widget.startLeft, endLeft, _c.value)!;

        // when running back, face left
        final flipX = _c.status == AnimationStatus.reverse;

        return Positioned(
          left: left,
          bottom: widget.bottom,
          top: 0,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(flipX ? -1.0 : 1.0, 1.0),
            child: Image.asset(
              'assets/image/pikachu_running.gif',
              height: widget.size,
              width: widget.size,
              filterQuality: FilterQuality.none,
            ),
          ),
        );
      },
    );
  }
}
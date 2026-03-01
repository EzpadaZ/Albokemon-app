import 'dart:ui';
import 'package:flutter/material.dart';

class SmoothColorText extends StatefulWidget {
  const SmoothColorText(
      this.text, {
        super.key,
        this.colorA = Colors.white,
        this.colorB = Colors.yellow,
        this.period = const Duration(milliseconds: 1200),
        this.style,
        this.textAlign,
        this.maxLines,
        this.overflow,

        // glass bg
        this.glass = true,
        this.blurSigma = 6,
        this.bgColor = const Color(0x66000000), // ~40% black
        this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        this.borderRadius = const BorderRadius.all(Radius.circular(10)),
        this.border,
      });

  final String text;
  final Color colorA;
  final Color colorB;
  final Duration period;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  final bool glass;
  final double blurSigma;
  final Color bgColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final BoxBorder? border;

  @override
  State<SmoothColorText> createState() => _SmoothColorTextState();
}

class _SmoothColorTextState extends State<SmoothColorText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat(reverse: true);

  late Animation<Color?> _color = ColorTween(
    begin: widget.colorA,
    end: widget.colorB,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

  @override
  void didUpdateWidget(covariant SmoothColorText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) _c.duration = widget.period;
    if (oldWidget.colorA != widget.colorA || oldWidget.colorB != widget.colorB) {
      _color = ColorTween(begin: widget.colorA, end: widget.colorB).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.style ?? DefaultTextStyle.of(context).style;

    Widget child = AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Text(
        widget.text,
        style: base.copyWith(color: _color.value),
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      ),
    );

    if (!widget.glass) return child;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: widget.borderRadius,
            border: widget.border ??
                Border.all(color: Colors.white.withOpacity(0.18), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius radius;
  final EdgeInsets padding;
  const LiquidGlass({super.key, required this.child, this.blur = 30, this.opacity = 0.15, this.radius = const BorderRadius.all(Radius.circular(24)), this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(opacity),
            borderRadius: radius,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isPressed;
  final Color baseColor;
  final double depth;
  final double spread;
  final EdgeInsetsGeometry padding;
  final BoxShape shape;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.isPressed = false,
    this.baseColor = const Color(0xFF1A1A1A),
    this.depth = 10,
    this.spread = 1,
    this.padding = const EdgeInsets.all(0),
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final offset = isPressed ? const Offset(0, 0) : Offset(depth, depth);
    final blur = isPressed ? 5.0 : depth * 2;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        boxShadow: [
          // Bottom-Right Dark Shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: offset,
            blurRadius: blur,
            spreadRadius: spread,
            inset: isPressed,
          ),
          // Top-Left Light Shadow
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            offset: isPressed ? const Offset(0, 0) : Offset(-depth / 2, -depth / 2),
            blurRadius: blur,
            spreadRadius: spread,
            inset: isPressed,
          ),
        ],
      ),
      child: child,
    );
  }
}

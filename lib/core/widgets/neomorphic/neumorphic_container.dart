import 'package:flutter/material.dart';

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
    this.depth = 8,
    this.spread = 1,
    this.padding = const EdgeInsets.all(0),
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    if (isPressed) {
      // Manual Inset Shadow Approximation using Inner Shadow technique
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: baseColor,
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: shape == BoxShape.circle ? BorderRadius.circular(100) : BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // Top-Left Dark Shadow (Inner)
              Positioned(
                top: -depth,
                left: -depth,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: shape,
                    borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: depth,
                        offset: Offset(depth / 2, depth / 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom-Right Light Shadow (Inner)
              Positioned(
                top: 0,
                left: 0,
                right: -depth,
                bottom: -depth,
                child: Container(
                  decoration: BoxDecoration(
                    shape: shape,
                    borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        blurRadius: depth,
                        offset: Offset(-depth / 2, -depth / 2),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      );
    }

    // Standard Outset Shadow (Embossed)
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        boxShadow: [
          // Bottom-Right Dark Shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: Offset(depth, depth),
            blurRadius: depth * 2,
            spreadRadius: spread,
          ),
          // Top-Left Light Shadow
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            offset: Offset(-depth / 2, -depth / 2),
            blurRadius: depth * 2,
            spreadRadius: spread,
          ),
        ],
      ),
      child: child,
    );
  }
}

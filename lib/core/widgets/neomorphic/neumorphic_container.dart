import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isPressed;
  final Color? baseColor;
  final double depth;
  final double spread;
  final EdgeInsetsGeometry padding;
  final BoxShape shape;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.isPressed = false,
    this.baseColor,
    this.depth = 8,
    this.spread = 1,
    this.padding = const EdgeInsets.all(0),
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Automatic base color based on theme if not provided
    final effectiveBaseColor = baseColor ?? theme.scaffoldBackgroundColor;

    // Shadow colors based on theme
    final darkShadow = isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.15);
    final lightShadow = isDark ? Colors.white.withOpacity(0.05) : Colors.white;

    if (isPressed) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveBaseColor,
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: shape == BoxShape.circle ? BorderRadius.circular(100) : BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
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
                        color: darkShadow,
                        blurRadius: depth,
                        offset: Offset(depth / 2, depth / 2),
                      ),
                    ],
                  ),
                ),
              ),
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
                        color: lightShadow,
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

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBaseColor,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: darkShadow,
            offset: Offset(depth, depth),
            blurRadius: depth * 2,
            spreadRadius: spread,
          ),
          BoxShadow(
            color: lightShadow,
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

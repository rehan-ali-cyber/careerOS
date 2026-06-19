import 'dart:ui';
import 'package:flutter/material.dart';

/**
 * GlassTheme: The definitive aesthetic blueprint of CareerOS.
 * Focuses on 'Liquid Glass' - high blur, ultra-low opacity, and hairline borders.
 */
class GlassTheme {

  // 1. THE SIGNATURE GLASS BOX
  static BoxDecoration glassDecoration({
    double opacity = 0.04,
    double blur = 20.0,
    BorderRadius? borderRadius,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(28),
      border: hasBorder ? Border.all(
        color: Colors.white.withOpacity(0.08),
        width: 0.8, // Ultra-thin hairline border
      ) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ],
    );
  }

  // 2. THE GLASS LAYER COMPONENT
  static Widget glassLayer({
    double blur = 20.0,
    BorderRadius? borderRadius,
    Widget? child
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }

  // 3. SOVEREIGN COLORS
  static const Color cyanGlow = Color(0xFF00FBFF);
  static const Color deepSeaBlue = Color(0xFF001220);
  static const Color mistWhite = Color(0x1AFFFFFF);

  // 4. THE LIQUID GRADIENT (Sovereign Legacy Name Kept for Compatibility)
  static LinearGradient waterGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF001220),
      Color(0xFF00334E),
      Color(0xFF000000),
    ],
  );

  static LinearGradient liquidGradient = waterGradient;
}

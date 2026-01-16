import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FrostedGlassCard extends StatelessWidget {
  const FrostedGlassCard({
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.child,
    this.margin,
    this.borderRadius = 18,
    this.gradient,
  });

  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final Widget? child;
  final double borderRadius;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.cardOutline),
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                AppColors.navyLayer,
                AppColors.navyLayer.withOpacity(.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: InkWell(
            splashColor: AppColors.accentTeal.withOpacity(.15),
            highlightColor: Colors.white.withOpacity(.04),
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );

    return card;
  }
}

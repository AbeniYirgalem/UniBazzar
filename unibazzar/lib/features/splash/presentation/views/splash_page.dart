import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/routing/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    const logoPath = 'assets/icon/app_icon.png';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size.width * 0.32,
              height: size.width * 0.32,
              constraints: const BoxConstraints(maxWidth: 180, maxHeight: 180),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  logoPath,
                  width: size.width * 0.22,
                  height: size.width * 0.22,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.storefront_rounded,
                    size: size.width * 0.18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            BouncingDots(controller: _controller),
          ],
        ),
      ),
    );
  }
}

class BouncingDots extends StatelessWidget {
  const BouncingDots({super.key, required this.controller});

  final AnimationController controller;
  static const int dots = 5;
  static const double travel = 10;

  Animation<double> _stagger(int index) {
    final start = index * 0.1;
    final end = start + 0.7;
    return CurvedAnimation(
      parent: controller,
      curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(dots, (index) {
        final animation = _stagger(index);
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final value = math.sin(animation.value * math.pi);
            return Transform.translate(
              offset: Offset(0, -value * travel),
              child: Opacity(
                opacity: 0.4 + (value * 0.6).clamp(0, 1),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        );
      }),
    );
  }
}

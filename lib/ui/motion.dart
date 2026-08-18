import 'package:flutter/material.dart';

class AppMotion {
  static const Duration press = Duration(milliseconds: 90);
  static const Duration lift = Duration(milliseconds: 120);
  static const Duration settle = Duration(milliseconds: 240);
  static const Duration overlay = Duration(milliseconds: 280);
  static const Duration page = Duration(milliseconds: 380);
  static const Duration countdown = Duration(milliseconds: 280);
  static const Duration stage = Duration(milliseconds: 420);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve spring = Curves.easeOutBack;

  static Widget overlayTransition(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(parent: animation, curve: easeOut);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
        child: child,
      ),
    );
  }

  static Future<T?> open<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push(
      PageRouteBuilder<T>(
        transitionDuration: page,
        reverseTransitionDuration: overlay,
        pageBuilder: (context, _, _) => screen,
        transitionsBuilder: (context, animation, _, child) {
          return fadeSlide(child, animation);
        },
      ),
    );
  }

  static Widget fadeSlide(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(parent: animation, curve: easeOut);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AppMotion.fadeSlide(child, animation);
  }
}

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onPressed,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onPressed != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: AppMotion.press,
        curve: AppMotion.easeOut,
        child: widget.child,
      ),
    );
  }
}

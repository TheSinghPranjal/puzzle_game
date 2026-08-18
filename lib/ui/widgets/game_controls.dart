import 'package:flutter/material.dart';
import 'package:puzzle_match/theme/app_theme.dart';
import 'package:puzzle_match/ui/motion.dart';

class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: primary ? Colors.white : AppTheme.accent,
      ),
    );
    final visual = primary
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: onPressed == null
                  ? null
                  : const LinearGradient(
                      colors: [AppTheme.accentDeep, AppTheme.accent],
                    ),
              color: onPressed == null ? Colors.grey : null,
              boxShadow: onPressed == null
                  ? null
                  : [
                      BoxShadow(
                        color: AppTheme.accentDeep.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: child),
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.accent, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: child),
            ),
          );
    final button = Pressable(
      onPressed: onPressed,
      child: expand ? SizedBox(width: double.infinity, child: visual) : visual,
    );
    return button;
  }
}

class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.overlay,
      switchInCurve: AppMotion.easeOut,
      child: Container(
        key: ValueKey(value),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.hint, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:puzzle_match/theme/app_theme.dart';

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
    final button = primary
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: onPressed == null
                  ? null
                  : const LinearGradient(
                      colors: [AppTheme.accentDeep, AppTheme.accent],
                    ),
              color: onPressed == null ? Colors.grey : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: child),
                ),
              ),
            ),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.accent, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: child,
          );
    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

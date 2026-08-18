import 'package:flutter/material.dart';
import 'package:puzzle_match/ui/motion.dart';

class AppTheme {
  static const background = Color(0xFF2C2C2C);
  static const surface = Color(0xFF3A3A3A);
  static const card = Color(0xFFF4EFE4);
  static const accent = Color(0xFFFF9F1C);
  static const accentDeep = Color(0xFFE85D04);
  static const hint = Color(0xFFFFD54F);
  static const success = Color(0xFF76FF03);
  static const tileSeparator = Color(0xFFD7C4A3);
  static const textMuted = Color(0xFFBDBDBD);

  static Color panel(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  static Color muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static ThemeData dark() => _base(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: accent,
      secondary: hint,
      surface: Color(0xFF1C222E),
      error: Color(0xFFE53935),
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFB0B8C4),
      surfaceContainerHighest: Color(0xFF2A3140),
    ),
    scaffold: const Color(0xFF0B1520),
    colors: PuzzleColors.dark,
  );

  static ThemeData light() => _base(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: accent,
      secondary: hint,
      surface: Color(0xFFFAF4E8),
      error: Color(0xFFE53935),
      onSurface: Color(0xFF1A140C),
      onSurfaceVariant: Color(0xFF6B6258),
      surfaceContainerHighest: Color(0xFFFFFBF3),
    ),
    scaffold: const Color(0xFFF4EBD8),
    colors: PuzzleColors.light,
  );

  static ThemeData _base({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffold,
    required PuzzleColors colors,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: 'Roboto',
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
        },
      ),
    );
  }
}

extension PuzzleThemeContext on BuildContext {
  PuzzleColors get puzzleColors =>
      Theme.of(this).extension<PuzzleColors>() ?? PuzzleColors.dark;
}

@immutable
class PuzzleColors extends ThemeExtension<PuzzleColors> {
  const PuzzleColors({
    required this.background,
    required this.backgroundMid,
    required this.backgroundEdge,
    required this.surface,
    required this.surfaceAltStart,
    required this.surfaceAltEnd,
    required this.chrome,
    required this.chromeBorder,
    required this.pillFill,
    required this.textPrimary,
    required this.textMuted,
    required this.titleFace,
    required this.titleDepth,
    required this.iconOnChrome,
    required this.outlineFill,
    required this.navBar,
    required this.navTile,
    required this.divider,
    required this.bannerFill,
    required this.bannerText,
    required this.mountainBack,
    required this.mountainMid,
    required this.mountainTree,
    required this.paw,
  });

  final Color background;
  final Color backgroundMid;
  final Color backgroundEdge;
  final Color surface;
  final Color surfaceAltStart;
  final Color surfaceAltEnd;
  final Color chrome;
  final Color chromeBorder;
  final Color pillFill;
  final Color textPrimary;
  final Color textMuted;
  final Color titleFace;
  final Color titleDepth;
  final Color iconOnChrome;
  final Color outlineFill;
  final Color navBar;
  final Color navTile;
  final Color divider;
  final Color bannerFill;
  final Color bannerText;
  final Color mountainBack;
  final Color mountainMid;
  final Color mountainTree;
  final Color paw;

  static const dark = PuzzleColors(
    background: Color(0xFF0B1520),
    backgroundMid: Color(0xFF121C28),
    backgroundEdge: Color(0xFF070B10),
    surface: Color(0xFF1C222E),
    surfaceAltStart: Color(0xFF1A2433),
    surfaceAltEnd: Color(0xFF121A26),
    chrome: Color(0xFF151E28),
    chromeBorder: Color(0xFF3A4652),
    pillFill: Color(0xD10E171F),
    textPrimary: Colors.white,
    textMuted: Color(0xFF8B97A6),
    titleFace: Colors.white,
    titleDepth: Color(0xFFB0B6BE),
    iconOnChrome: Color(0xFFC5CDD4),
    outlineFill: Color(0xFF0A1018),
    navBar: Color(0xF00B1520),
    navTile: Color(0xFF1A2734),
    divider: Color(0xFF2A384D),
    bannerFill: Color(0xCC161C28),
    bannerText: Color(0xFFB0B8C4),
    mountainBack: Color(0xFF101820),
    mountainMid: Color(0xFF0B1218),
    mountainTree: Color(0xFF080E14),
    paw: Colors.white,
  );

  static const light = PuzzleColors(
    background: Color(0xFFF4EBD8),
    backgroundMid: Color(0xFFFAF4E8),
    backgroundEdge: Color(0xFFE4D6BC),
    surface: Color(0xFFFFFBF3),
    surfaceAltStart: Color(0xFFFFF8EC),
    surfaceAltEnd: Color(0xFFF0E6D2),
    chrome: Color(0xFFFFFBF3),
    chromeBorder: Color(0xFFD4C4A8),
    pillFill: Color(0xE6FFFFFF),
    textPrimary: Color(0xFF1A140C),
    textMuted: Color(0xFF6B6258),
    titleFace: Color(0xFF1A140C),
    titleDepth: Color(0xFFC4B8A4),
    iconOnChrome: Color(0xFF4A4036),
    outlineFill: Color(0xFFFFFBF3),
    navBar: Color(0xF0FFFBF3),
    navTile: Color(0xFFFFF0D4),
    divider: Color(0xFFDDD0B8),
    bannerFill: Color(0xE6FFFFFF),
    bannerText: Color(0xFF6B6258),
    mountainBack: Color(0xFFD4C8B0),
    mountainMid: Color(0xFFC4B69A),
    mountainTree: Color(0xFFA89878),
    paw: Color(0xFF3A2A18),
  );

  @override
  PuzzleColors copyWith({
    Color? background,
    Color? backgroundMid,
    Color? backgroundEdge,
    Color? surface,
    Color? surfaceAltStart,
    Color? surfaceAltEnd,
    Color? chrome,
    Color? chromeBorder,
    Color? pillFill,
    Color? textPrimary,
    Color? textMuted,
    Color? titleFace,
    Color? titleDepth,
    Color? iconOnChrome,
    Color? outlineFill,
    Color? navBar,
    Color? navTile,
    Color? divider,
    Color? bannerFill,
    Color? bannerText,
    Color? mountainBack,
    Color? mountainMid,
    Color? mountainTree,
    Color? paw,
  }) {
    return PuzzleColors(
      background: background ?? this.background,
      backgroundMid: backgroundMid ?? this.backgroundMid,
      backgroundEdge: backgroundEdge ?? this.backgroundEdge,
      surface: surface ?? this.surface,
      surfaceAltStart: surfaceAltStart ?? this.surfaceAltStart,
      surfaceAltEnd: surfaceAltEnd ?? this.surfaceAltEnd,
      chrome: chrome ?? this.chrome,
      chromeBorder: chromeBorder ?? this.chromeBorder,
      pillFill: pillFill ?? this.pillFill,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      titleFace: titleFace ?? this.titleFace,
      titleDepth: titleDepth ?? this.titleDepth,
      iconOnChrome: iconOnChrome ?? this.iconOnChrome,
      outlineFill: outlineFill ?? this.outlineFill,
      navBar: navBar ?? this.navBar,
      navTile: navTile ?? this.navTile,
      divider: divider ?? this.divider,
      bannerFill: bannerFill ?? this.bannerFill,
      bannerText: bannerText ?? this.bannerText,
      mountainBack: mountainBack ?? this.mountainBack,
      mountainMid: mountainMid ?? this.mountainMid,
      mountainTree: mountainTree ?? this.mountainTree,
      paw: paw ?? this.paw,
    );
  }

  @override
  PuzzleColors lerp(ThemeExtension<PuzzleColors>? other, double t) {
    if (other is! PuzzleColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return PuzzleColors(
      background: mix(background, other.background),
      backgroundMid: mix(backgroundMid, other.backgroundMid),
      backgroundEdge: mix(backgroundEdge, other.backgroundEdge),
      surface: mix(surface, other.surface),
      surfaceAltStart: mix(surfaceAltStart, other.surfaceAltStart),
      surfaceAltEnd: mix(surfaceAltEnd, other.surfaceAltEnd),
      chrome: mix(chrome, other.chrome),
      chromeBorder: mix(chromeBorder, other.chromeBorder),
      pillFill: mix(pillFill, other.pillFill),
      textPrimary: mix(textPrimary, other.textPrimary),
      textMuted: mix(textMuted, other.textMuted),
      titleFace: mix(titleFace, other.titleFace),
      titleDepth: mix(titleDepth, other.titleDepth),
      iconOnChrome: mix(iconOnChrome, other.iconOnChrome),
      outlineFill: mix(outlineFill, other.outlineFill),
      navBar: mix(navBar, other.navBar),
      navTile: mix(navTile, other.navTile),
      divider: mix(divider, other.divider),
      bannerFill: mix(bannerFill, other.bannerFill),
      bannerText: mix(bannerText, other.bannerText),
      mountainBack: mix(mountainBack, other.mountainBack),
      mountainMid: mix(mountainMid, other.mountainMid),
      mountainTree: mix(mountainTree, other.mountainTree),
      paw: mix(paw, other.paw),
    );
  }
}

import 'package:flutter/material.dart';

/// Palette: Calm Professional
class AppColors {
  // Core
  static const Color primary = Color(0xFF1565C0); // Deep Blue
  static const Color accent = Color(0xFF00897B); // Teal (CTA)
  /// Use this as the default scaffold background color. `background` is kept
  /// for compatibility but deprecated: prefer [scaffoldBackground].
  static const Color scaffoldBackground = Color(0xFFF6F8FA); // Off‑white
  @Deprecated(
    'Use AppColors.scaffoldBackground instead. Will be removed in a future release.',
  )
  static const Color background = scaffoldBackground;
  static const Color surface = Color(0xFFFFFFFF); // Card surface
  static const Color textPrimary = Color(0xFF1F2933); // Charcoal
  static const Color textMuted = Color(0xFF6B7280); // Gray

  // Status
  static const Color success = Color(0xFF22C55E); // Confirmed
  static const Color warning = Color(0xFFF59E0B); // Pending
  static const Color error = Color(0xFFEF4444); // Cancelled

  // Tile / CTA color (matches screenshot orange)
  static const Color tile = Color(0xFFF57C00); // Orange 600
  static const Color tileDark = Color(
    0xFFB35A00,
  ); // Darker orange for dark mode

  // Dark variants (tuned)
  /// Dark mode scaffold background.
  static const Color scaffoldBackgroundDark = Color(0xFF0B1220);
  @Deprecated(
    'Use AppColors.scaffoldBackgroundDark instead. Will be removed in a future release.',
  )
  static const Color darkBackground = scaffoldBackgroundDark;
  static const Color darkSurface = Color(0xFF0F1724);
  static const Color primaryLight = Color(0xFF90CAF9); // for dark theme accents
  static const Color accentLight = Color(0xFF4DB6AC);
}

/// Light ThemeData
ThemeData lightTheme() {
  // Build a full ColorScheme derived from a seed color to avoid deprecated
  // `background` properties (use surfaces instead). We still wire in our
  // custom colors for surface/primary/secondary to keep the palette.
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: Colors.white,
  );

  return ThemeData(
    colorScheme: colorScheme,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    canvasColor: AppColors.surface,
    appBarTheme: AppBarTheme(
      // Use the color scheme's primary/onPrimary so AppBar matches other
      // widgets consistently across light/dark variants and per-screen
      // AppBars that don't override the background.
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
      centerTitle: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textMuted, fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: TextStyle(color: AppColors.textPrimary),
    ),
    dividerColor: Colors.grey.shade200,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

/// Dark ThemeData
ThemeData darkTheme() {
  // Use ColorScheme.fromSeed to derive the dark scheme and avoid the
  // deprecated `background` slot — prefer `surface` and `scaffoldBackgroundColor`.
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryLight,
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: AppColors.darkSurface,
    secondary: AppColors.accentLight,
    onSecondary: AppColors.darkSurface,
    surface: AppColors.darkSurface,
    onSurface: Colors.white,
    error: AppColors.error,
    onError: AppColors.darkSurface,
  );

  return ThemeData(
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.scaffoldBackgroundDark,
    canvasColor: AppColors.darkSurface,
    appBarTheme: AppBarTheme(
      // Use colorScheme.primary in dark mode too to avoid discrepancies
      // between screens that explicitly use `theme.colorScheme.primary`
      // and those relying on the AppBarTheme background color.
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 1,
      centerTitle: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentLight,
      foregroundColor: AppColors.darkSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentLight,
        foregroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.grey.shade300, fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurface,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    dividerColor: Colors.white24,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

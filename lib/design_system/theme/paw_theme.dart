import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/paw_colors.dart';
import '../tokens/paw_typography.dart';
import '../tokens/paw_spacing.dart';
import '../tokens/paw_elevation.dart';
import '../tokens/paw_radius.dart';



class PawTheme {
  
  static ThemeData get lightTheme {
    return theme.copyWith(
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: _lightTextTheme,
      primaryColor: PawColors.primary,
      scaffoldBackgroundColor: _lightBackground,
      canvasColor: _lightBackground,
      cardColor: _lightCardBackground,
      dividerColor: _lightDivider,
      disabledColor: _lightTextDisabled,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBackground,
        foregroundColor: _lightTextPrimary,
        elevation: PawElevation.appBar,
        centerTitle: false,
        titleTextStyle: _lightTextTheme.titleLarge?.copyWith(
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightCardBackground,
        selectedItemColor: PawColors.primary,
        unselectedItemColor: _lightTextSecondary,
        elevation: PawElevation.bottomNav,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: _lightCardBackground,
        elevation: PawElevation.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PawRadius.card),
          side: const BorderSide(color: PawColors.primary),
        ),
        margin: const EdgeInsets.all(PawSpacing.sm),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightCardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PawSpacing.md,
          vertical: PawSpacing.sm,
        ),
        labelStyle: _lightTextTheme.bodyMedium?.copyWith(
          color: _lightTextSecondary,
        ),
        prefixIconColor: PawColors.primary,
        suffixIconColor: _lightTextPrimary,
        hintStyle: _lightTextTheme.bodyMedium?.copyWith(
          color: _lightTextTertiary,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _lightBorder),
          borderRadius: BorderRadius.circular(PawRadius.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: PawColors.primary, width: 2),
          borderRadius: BorderRadius.circular(PawRadius.input),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: _lightTextTheme.bodyLarge,
        subtitleTextStyle: _lightTextTheme.bodyMedium?.copyWith(
          color: _lightTextSecondary,
        ),
        iconColor: _lightTextPrimary,
      ),
      extensions: <ThemeExtension<dynamic>>[
        const PawThemeExtension(
          brandPrimary: PawColors.primary,
          brandSecondary: PawColors.secondary,
          successColor: PawColors.success,
          warningColor: PawColors.warning,
          errorColor: PawColors.error,
          infoColor: PawColors.info,
          cardBackgroundHover: _lightCardHover,
          surfaceElevated: _lightSurfaceElevated,
        ),
      ],
    );
  }

  
  static ThemeData get theme {
    return ThemeData(
      
      useMaterial3: true,
      brightness: Brightness.dark,

      
      colorScheme: _colorScheme,

      
      textTheme: _textTheme,

      
      primaryColor: PawColors.primary,
      scaffoldBackgroundColor: PawColors.background,
      canvasColor: PawColors.background,
      cardColor: PawColors.cardBackground,
      dividerColor: PawColors.divider,
      disabledColor: PawColors.textDisabled,

      
      appBarTheme: AppBarTheme(
        backgroundColor: PawColors.background,
        foregroundColor: PawColors.textPrimary,
        elevation: PawElevation.appBar,
        centerTitle: false,
        titleTextStyle: PawTypography.h2,
        iconTheme: const IconThemeData(color: PawColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: PawColors.cardBackground,
        selectedItemColor: PawColors.primary,
        unselectedItemColor: PawColors.textSecondary,
        elevation: PawElevation.bottomNav,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: PawTypography.labelSmall,
        unselectedLabelStyle: PawTypography.labelSmall,
      ),

      
      cardTheme: CardThemeData(
        color: PawColors.cardBackground,
        elevation: PawElevation.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PawRadius.card),
        ),
        margin: const EdgeInsets.all(PawSpacing.sm),
      ),

      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PawColors.primary,
          foregroundColor: Colors.white,
          elevation: PawElevation.button,
          padding: const EdgeInsets.symmetric(
            horizontal: PawSpacing.md,
            vertical: PawSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawRadius.button),
          ),
          textStyle: PawTypography.labelLarge,
          minimumSize: const Size(0, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PawColors.primary,
          side: const BorderSide(color: PawColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: PawSpacing.md,
            vertical: PawSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawRadius.button),
          ),
          textStyle: PawTypography.labelLarge,
          minimumSize: const Size(0, 48),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PawColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: PawSpacing.md,
            vertical: PawSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawRadius.button),
          ),
          textStyle: PawTypography.labelLarge,
          minimumSize: const Size(0, 48),
        ),
      ),

      
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: PawColors.textPrimary,
          padding: const EdgeInsets.all(PawSpacing.sm),
        ),
      ),

      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PawColors.primary,
        foregroundColor: Colors.white,
        elevation: PawElevation.fab,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PawRadius.lg),
        ),
      ),

      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PawColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PawSpacing.md,
          vertical: PawSpacing.sm,
        ),
        labelStyle: PawTypography.bodyMedium.copyWith(
          color: PawColors.textSecondary,
        ),
        hintStyle: PawTypography.bodyMedium.copyWith(
          color: PawColors.textTertiary,
        ),
        helperStyle: PawTypography.bodySmall.copyWith(
          color: PawColors.textTertiary,
        ),
        errorStyle: PawTypography.bodySmall.copyWith(color: PawColors.error),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: PawColors.border, width: 1),
          borderRadius: BorderRadius.circular(PawRadius.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: PawColors.primary, width: 2),
          borderRadius: BorderRadius.circular(PawRadius.input),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: PawColors.error, width: 1),
          borderRadius: BorderRadius.circular(PawRadius.input),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: PawColors.error, width: 2),
          borderRadius: BorderRadius.circular(PawRadius.input),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: PawColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(PawRadius.input),
        ),
      ),

      
      chipTheme: ChipThemeData(
        backgroundColor: PawColors.cardBackground,
        selectedColor: PawColors.primary,
        disabledColor: PawColors.cardBackground.withValues(alpha: 0.5),
        labelStyle: PawTypography.labelMedium,
        secondaryLabelStyle: PawTypography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: PawSpacing.sm,
          vertical: PawSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PawRadius.chip),
          side: const BorderSide(color: PawColors.border),
        ),
      ),

      
      dialogTheme: DialogThemeData(
        backgroundColor: PawColors.cardBackground,
        elevation: PawElevation.dialog,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PawRadius.dialog),
        ),
        titleTextStyle: PawTypography.h2,
        contentTextStyle: PawTypography.bodyMedium,
      ),

      
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: PawColors.cardBackground,
        elevation: PawElevation.modal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PawRadius.bottomSheet),
          ),
        ),
        modalBackgroundColor: PawColors.cardBackground,
        modalElevation: PawElevation.modal,
      ),

      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PawColors.surfaceElevated,
        contentTextStyle: PawTypography.bodyMedium,
        actionTextColor: PawColors.primary,
        elevation: PawElevation.high,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PawRadius.sm),
        ),
      ),

      
      dividerTheme: const DividerThemeData(
        color: PawColors.divider,
        thickness: 1,
        space: 1,
      ),

      
      listTileTheme: ListTileThemeData(
        contentPadding: PawSpacing.listItemInsets,
        titleTextStyle: PawTypography.bodyLarge,
        subtitleTextStyle: PawTypography.bodyMedium.copyWith(
          color: PawColors.textSecondary,
        ),
        iconColor: PawColors.textPrimary,
      ),

      
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return PawColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PawColors.primary;
          }
          return PawColors.border;
        }),
      ),

      
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PawColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: PawColors.border, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PawColors.primary;
          }
          return PawColors.border;
        }),
      ),

      
      sliderTheme: SliderThemeData(
        activeTrackColor: PawColors.primary,
        inactiveTrackColor: PawColors.border,
        thumbColor: PawColors.primary,
        overlayColor: PawColors.primary.withValues(alpha: 0.2),
        valueIndicatorColor: PawColors.primary,
        valueIndicatorTextStyle: PawTypography.bodySmall.copyWith(
          color: Colors.white,
        ),
      ),

      
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PawColors.primary,
        linearTrackColor: PawColors.border,
        circularTrackColor: PawColors.border,
      ),

      
      tabBarTheme: TabBarThemeData(
        labelColor: PawColors.primary,
        unselectedLabelColor: PawColors.textSecondary,
        labelStyle: PawTypography.labelMedium,
        unselectedLabelStyle: PawTypography.labelMedium,
        indicatorColor: PawColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: PawColors.surfaceElevated,
          borderRadius: BorderRadius.circular(PawRadius.sm),
        ),
        textStyle: PawTypography.bodySmall.copyWith(
          color: PawColors.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: PawSpacing.sm,
          vertical: PawSpacing.xs,
        ),
      ),

      
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: PawColors.cardBackground,
        contentTextStyle: PawTypography.bodyMedium,
      ),

      
      badgeTheme: const BadgeThemeData(
        backgroundColor: PawColors.error,
        textColor: Colors.white,
        smallSize: 6,
        largeSize: 16,
      ),

      
      extensions: <ThemeExtension<dynamic>>[
        PawThemeExtension(
          brandPrimary: PawColors.primary,
          brandSecondary: PawColors.secondary,
          successColor: PawColors.success,
          warningColor: PawColors.warning,
          errorColor: PawColors.error,
          infoColor: PawColors.info,
          cardBackgroundHover: PawColors.cardBackgroundHover,
          surfaceElevated: PawColors.surfaceElevated,
        ),
      ],
    );
  }

  
  static const ColorScheme _colorScheme = ColorScheme.dark(
    
    primary: PawColors.primary,
    onPrimary: Colors.white,
    primaryContainer: PawColors.primaryDark,
    onPrimaryContainer: PawColors.primaryLight,

    
    secondary: PawColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: PawColors.accent,
    onSecondaryContainer: PawColors.textPrimary,

    
    surface: PawColors.background,
    onSurface: PawColors.textPrimary,
    surfaceContainerHighest: PawColors.cardBackground,
    onSurfaceVariant: PawColors.textSecondary,

    
    error: PawColors.error,
    onError: Colors.white,
    errorContainer: PawColors.errorLight,
    onErrorContainer: PawColors.textPrimary,

    
    outline: PawColors.border,
    outlineVariant: PawColors.borderLight,
    shadow: Colors.black,
    scrim: PawColors.overlay,
    inverseSurface: PawColors.textPrimary,
    onInverseSurface: PawColors.background,
    inversePrimary: PawColors.primaryLight,
  );

  static const Color _lightBackground = Colors.white;
  static const Color _lightCardBackground = Colors.white;
  static const Color _lightCardHover = Color(0xFFE8F1F8);
  static const Color _lightSurfaceElevated = Colors.white;
  static const Color _lightTextPrimary = Colors.black;
  static const Color _lightTextSecondary = Colors.black;
  static const Color _lightTextTertiary = Colors.black;
  static const Color _lightTextDisabled = Color(0xFF9AA5B1);
  static const Color _lightBorder = PawColors.primary;
  static const Color _lightDivider = PawColors.primary;

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: PawColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD7EFFB),
    onPrimaryContainer: PawColors.primaryDark,
    secondary: PawColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFE1E1),
    onSecondaryContainer: Color(0xFF7F1D1D),
    surface: _lightBackground,
    onSurface: _lightTextPrimary,
    surfaceContainerHighest: _lightCardBackground,
    onSurfaceVariant: _lightTextSecondary,
    error: PawColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFE0E0),
    onErrorContainer: Color(0xFF7F1D1D),
    outline: _lightBorder,
    outlineVariant: Color(0xFFBCCCDC),
    shadow: Colors.black,
    scrim: Color(0x80000000),
    inverseSurface: _lightTextPrimary,
    onInverseSurface: Colors.white,
    inversePrimary: PawColors.primaryLight,
  );

  static final TextTheme _lightTextTheme = TextTheme(
    displayLarge: PawTypography.displayLarge.copyWith(color: _lightTextPrimary),
    displayMedium: PawTypography.h1.copyWith(color: _lightTextPrimary),
    displaySmall: PawTypography.h2.copyWith(color: _lightTextPrimary),
    headlineLarge: PawTypography.h1.copyWith(color: _lightTextPrimary),
    headlineMedium: PawTypography.h2.copyWith(color: _lightTextPrimary),
    headlineSmall: PawTypography.h3.copyWith(color: _lightTextPrimary),
    titleLarge: PawTypography.h2.copyWith(color: _lightTextPrimary),
    titleMedium: PawTypography.h3.copyWith(color: _lightTextPrimary),
    titleSmall: PawTypography.labelLarge.copyWith(color: _lightTextPrimary),
    bodyLarge: PawTypography.bodyLarge.copyWith(color: _lightTextPrimary),
    bodyMedium: PawTypography.bodyMedium.copyWith(color: _lightTextPrimary),
    bodySmall: PawTypography.bodySmall.copyWith(color: _lightTextSecondary),
    labelLarge: PawTypography.labelLarge.copyWith(color: _lightTextPrimary),
    labelMedium: PawTypography.labelMedium.copyWith(color: _lightTextPrimary),
    labelSmall: PawTypography.labelSmall.copyWith(color: _lightTextSecondary),
  );

  
  static final TextTheme _textTheme = TextTheme(
    
    displayLarge: PawTypography.displayLarge,
    displayMedium: PawTypography.h1,
    displaySmall: PawTypography.h2,

    
    headlineLarge: PawTypography.h1,
    headlineMedium: PawTypography.h2,
    headlineSmall: PawTypography.h3,

    
    titleLarge: PawTypography.h2,
    titleMedium: PawTypography.h3,
    titleSmall: PawTypography.labelLarge,

    
    bodyLarge: PawTypography.bodyLarge,
    bodyMedium: PawTypography.bodyMedium,
    bodySmall: PawTypography.bodySmall,

    
    labelLarge: PawTypography.labelLarge,
    labelMedium: PawTypography.labelMedium,
    labelSmall: PawTypography.labelSmall,
  );

  
  PawTheme._();
}



class PawThemeExtension extends ThemeExtension<PawThemeExtension> {
  final Color brandPrimary;
  final Color brandSecondary;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;
  final Color infoColor;
  final Color cardBackgroundHover;
  final Color surfaceElevated;

  const PawThemeExtension({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
    required this.infoColor,
    required this.cardBackgroundHover,
    required this.surfaceElevated,
  });

  @override
  ThemeExtension<PawThemeExtension> copyWith({
    Color? brandPrimary,
    Color? brandSecondary,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? infoColor,
    Color? cardBackgroundHover,
    Color? surfaceElevated,
  }) {
    return PawThemeExtension(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      infoColor: infoColor ?? this.infoColor,
      cardBackgroundHover: cardBackgroundHover ?? this.cardBackgroundHover,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    );
  }

  @override
  ThemeExtension<PawThemeExtension> lerp(
    ThemeExtension<PawThemeExtension>? other,
    double t,
  ) {
    if (other is! PawThemeExtension) {
      return this;
    }
    return PawThemeExtension(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
      cardBackgroundHover: Color.lerp(
        cardBackgroundHover,
        other.cardBackgroundHover,
        t,
      )!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
    );
  }

  
  static PawThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<PawThemeExtension>()!;
  }
}

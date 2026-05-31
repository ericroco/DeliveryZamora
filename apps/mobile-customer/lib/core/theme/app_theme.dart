import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.card,
        ),
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      );
}

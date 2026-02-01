import 'package:flutter/material.dart';

class ResponsiveSizes {
  // Breakpoints
  static const double mobileSmall = 320;
  static const double mobileMedium = 480;
  static const double mobileRegular = 600;
  static const double tablet = 768;
  static const double desktop = 1024;

  // Padding values
  static const double paddingSmall = 4.0;
  static const double paddingMedium = 8.0;
  static const double paddingLarge = 12.0;
  static const double paddingExtraLarge = 16.0;
  static const double paddingXXL = 24.0;

  // Spacing values
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingExtraLarge = 24.0;

  // Get responsive horizontal padding
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileMedium) return paddingMedium;
    if (width < mobileRegular) return paddingLarge;
    if (width < tablet) return paddingExtraLarge;
    return paddingXXL;
  }

  // Get responsive vertical padding
  static double getVerticalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileMedium) return paddingSmall;
    if (width < mobileRegular) return paddingMedium;
    if (width < tablet) return paddingLarge;
    return paddingExtraLarge;
  }

  // Get responsive spacing for content
  static double getContentSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileMedium) return spacingSmall;
    if (width < mobileRegular) return spacingMedium;
    if (width < tablet) return spacingLarge;
    return spacingExtraLarge;
  }

  // Check if device is small (mobile)
  static bool isSmallDevice(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileRegular;
  }

  // Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }

  // Check if device is tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }
}

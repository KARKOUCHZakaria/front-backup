import 'package:flutter/widgets.dart';

/// Centralized image asset references. Replace the file names here
/// with the exported Figma asset file names to update the app in one place.
class ImageAssets {
  static const String onboarding1 = 'assets/images/node_10_2_illustration.png';
  static const String onboardingExplainable =
      'assets/images/node_13_17_explainable.png';
  static const String financials = 'assets/images/node_13_41_financials.png';
  static const String score = 'assets/images/node_15_176_score.png';
  static const String placeholder = 'assets/images/placeholder.png';

  static Image image(String path, {BoxFit fit = BoxFit.contain}) =>
      Image.asset(path, fit: fit);
}

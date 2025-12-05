// utils/color_utils.dart
import 'dart:ui';

class ColorUtils {
  static Color? colorFromInt(int? value) {
    return value != null ? Color(value) : null;
  }

  static int? colorToInt(Color? color) {
    return color?.value;
  }
}
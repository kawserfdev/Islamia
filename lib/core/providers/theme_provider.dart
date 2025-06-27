// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// // Provider for theme mode
// final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
//   final box = Hive.box(HiveConstants.settingsBox);
//   final isDarkMode = box.get('isDarkMode', defaultValue: false) as bool;
//   return ThemeNotifier(isDarkMode);
// });

// class ThemeNotifier extends StateNotifier<bool> {
//   ThemeNotifier(bool isDarkMode) : super(isDarkMode);
  
//   void toggleTheme() async {
//     final box = Hive.box(HiveConstants.settingsBox);
//     state = !state;
//     await box.put('isDarkMode', state);
//   }
  
//   void setDarkMode(bool isDarkMode) async {
//     final box = Hive.box(HiveConstants.settingsBox);
//     state = isDarkMode;
//     await box.put('isDarkMode', isDarkMode);
//   }
// }
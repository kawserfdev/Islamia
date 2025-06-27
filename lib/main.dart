import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/constants/themes.dart';
import 'package:islamia/core/providers/theme_provider.dart'; 
import 'package:islamia/features/home/presentation/pages/home_page.dart';
import 'package:islamia/firebase_options.dart';

void main() async {
  // Make main async
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   // final isDarkMode = ref.watch(themeProvider);
    // configLoading(
    //   isDarkMode: isDarkMode,
    //   indicatorColor: AppTheme.lightPrimary,
    //   backgroundColor: isDarkMode ? AppTheme.darkBackground : Colors.white,
    // );
    return MaterialApp(
      title: 'Islamia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      //themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomePage(),
    );
  }
}



void configLoading({
  required bool isDarkMode,
  required Color indicatorColor,
  required Color backgroundColor,
}) {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = indicatorColor
    ..backgroundColor = backgroundColor
    ..indicatorColor = indicatorColor
    ..textColor = isDarkMode ? Colors.white : Colors.black
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}
 
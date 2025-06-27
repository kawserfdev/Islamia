// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:islamia/core/constants/themes.dart';
// import 'package:islamia/core/providers/theme_provider.dart'; 
// import 'package:islamia/features/home/presentation/pages/home_page.dart';
// import 'package:islamia/firebase_options.dart';

// void main() async {
//   // Make main async
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(ProviderScope(child: const MyApp()));
// }

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//    // final isDarkMode = ref.watch(themeProvider);
//     // configLoading(
//     //   isDarkMode: isDarkMode,
//     //   indicatorColor: AppTheme.lightPrimary,
//     //   backgroundColor: isDarkMode ? AppTheme.darkBackground : Colors.white,
//     // );
//     return MaterialApp(
//       title: 'Islamia',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       //themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
//       home: const HomePage(),
//     );
//   }
// }



// // void configLoading({
// //   required bool isDarkMode,
// //   required Color indicatorColor,
// //   required Color backgroundColor,
// // }) {
// //   EasyLoading.instance
// //     ..displayDuration = const Duration(milliseconds: 2000)
// //     ..indicatorType = EasyLoadingIndicatorType.fadingCircle
// //     ..loadingStyle = EasyLoadingStyle.custom
// //     ..indicatorSize = 45.0
// //     ..radius = 10.0
// //     ..progressColor = indicatorColor
// //     ..backgroundColor = backgroundColor
// //     ..indicatorColor = indicatorColor
// //     ..textColor = isDarkMode ? Colors.white : Colors.black
// //     ..maskColor = Colors.black.withOpacity(0.5)
// //     ..userInteractions = false
// //     ..dismissOnTap = false;
// // }
 





 import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/constants/themes.dart';
import 'package:islamia/core/services/storage/local_storage_service.dart';
import 'package:islamia/features/home/presentation/pages/home_page.dart';
import 'core/config/firebase_config.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await FirebaseConfig.initialize();
    
    // Initialize local storage
    await LocalStorageService().prefs;
    
    // Initialize SQLite database for app data
    await DatabaseHelper().database;
    
    runApp(const ProviderScope(child: IslamiaApp()));
  } catch (e) {
    print('App initialization error: $e');
    runApp( MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize app: $e'),
        ),
      ),
    ));
  }
}

class IslamiaApp extends ConsumerWidget {
  const IslamiaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Islamia - Islamic Practice App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home:  ProfileScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
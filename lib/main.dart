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
 





//  import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:islamia/core/constants/themes.dart';
// import 'package:islamia/core/services/storage/local_storage_service.dart';
// import 'package:islamia/features/home/presentation/pages/home_page.dart';
// import 'core/config/firebase_config.dart';
// import 'core/database/database_helper.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   try {
//     // Initialize Firebase

//     await FirebaseConfig.initialize();
    
//     // Initialize local storage
//     await LocalStorageService().prefs;
    
//     // Initialize SQLite database for app data
//     await DatabaseHelper().database;
    
//     runApp(const ProviderScope(child: IslamiaApp()));
//   } catch (e) {
//     print('App initialization error: $e');
//     runApp( MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Failed to initialize app: $e'),
//         ),
//       ),
//     ));
//   }
// }

// class IslamiaApp extends ConsumerWidget {
//   const IslamiaApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return MaterialApp(
//       title: 'Islamia - Islamic Practice App',
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: ThemeMode.system,
//       home:  HomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/constants/themes.dart';
import 'package:islamia/core/services/storage/local_storage_service.dart';
import 'package:islamia/features/auth/complete_profile_screen.dart';
import 'package:islamia/features/auth/email_verification_screen.dart';
import 'package:islamia/features/auth/login_page.dart';
import 'package:islamia/features/auth/password_reset_screen.dart';
import 'package:islamia/features/auth/phone_sign_in_screen.dart';
import 'package:islamia/features/auth/sign_up_screen.dart';
import 'package:islamia/features/home/pages/home_page.dart';
import 'package:islamia/features/profile/profile_screen.dart';
import 'package:islamia/presentation/providers/theme_provider.dart';
import 'core/config/firebase_config.dart';
import 'core/database/database_helper.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  try {
    // Initialize Firebase
    await FirebaseConfig.initialize();
    
    // Initialize local storage
    await LocalStorageService().prefs;
    
    // Initialize SQLite database for app data (Quran, Hadith, etc.)
    await DatabaseHelper().database;
    
    runApp(const ProviderScope(child: IslamiaApp()));
  } catch (e) {
    print('App initialization error: $e');
    runApp(
      MaterialApp(
        title: 'Islamia - Initialization Error',
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to Initialize App',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: $e',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: const Text('Close App'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class IslamiaApp extends ConsumerWidget {
  const IslamiaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Islamia - Islamic Practice App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/sign-in': (context) => const SignInScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/phone-sign-in': (context) => const PhoneSignInScreen(),
        '/email-verification': (context) => const EmailVerificationScreen(),
        '/complete-profile': (context) => const CompleteProfileScreen(),
        '/password-reset': (context) => const PasswordResetScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        //'':(context)=> QuranReaderScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle parameterized routes
        if (settings.name == '/password-reset') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => PasswordResetScreen(
              email: args?['email'],
              oobCode: args?['oobCode'],
            ),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/auth_provider.dart';
import 'package:islamia/core/services/quran/initialization_service.dart'; // Added import
import 'package:islamia/core/services/storage/local_storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward(); // Start animation immediately
    // _performAuthCheckAndNavigate(); // Will be called by build method based on quranInitState
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // _animationController.forward(); // Now called in initState
  }

  // Renamed from _checkAuthStatus / _initializeAndNavigate
  // This method now assumes Quran services are initialized successfully.
  bool _navigationStarted = false; // Flag to prevent multiple navigation attempts
  Future<void> _performAuthCheckAndNavigate() async {
    // Ensure this logic only runs once
    if (_navigationStarted) return;
    _navigationStarted = true;

    try {
      // Ensure splash animations have a good chance to play
      await Future.delayed(const Duration(seconds: 2));

      final localStorage = LocalStorageService();
      final isLoggedIn = await localStorage.isLoggedIn();
      
      if (isLoggedIn) {
        // Check if user is still authenticated with Firebase
        final authService = ref.read(authServiceProvider);
        if (authService.isAuthenticated) {
          _navigateToHome();
        } else {
          _navigateToSignIn();
        }
      } else {
        _navigateToSignIn();
      }
    } catch (e) {
      // Catch-all for other errors during this process
      print('Error during splash screen initialization or auth check: $e');
      _navigateToSignIn(); // Fallback to sign-in
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _navigateToSignIn() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/sign-in');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranInitState = ref.watch(quranServicesInitializationProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: quranInitState.when(
        data: (_) {
          // Quran services initialized successfully.
          // Schedule navigation for after this build frame.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _performAuthCheckAndNavigate();
          });
          // Return the standard splash UI while waiting for navigation.
          return _buildAnimatedSplashUI(context, isLoading: true); // Show loader until navigation
        },
        loading: () {
          // Still loading Quran services.
          return _buildAnimatedSplashUI(context, isLoading: true);
        },
        error: (err, stack) {
          // Error initializing Quran services.
          return _buildErrorUI(context, err, stack);
        },
      ),
    );
  }

  // Helper widget for the animated splash screen content
  Widget _buildAnimatedSplashUI(BuildContext context, {required bool isLoading}) {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mosque,
                      size: 80,
                      color: Color(0xFF2E7D32), // Green color for the icon
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Islamia',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Islamic Practice App',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (isLoading)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget for displaying error UI
  Widget _buildErrorUI(BuildContext context, Object error, StackTrace? stackTrace) {
    // Optional: Log the error for developers
    debugPrint('Quran Initialization Error: $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white70, // Light color for dark background
              size: 70,
            ),
            const SizedBox(height: 24),
            const Text(
              'Initialization Failed',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'An error occurred while preparing essential app data. Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _navigationStarted = false; // Reset flag before retrying
                ref.invalidate(quranServicesInitializationProvider); // Invalidate to force re-fetch
              },
            ),
          ],
        ),
      ),
    );
  }
}
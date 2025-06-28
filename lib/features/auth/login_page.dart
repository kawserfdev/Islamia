import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/auth_provider.dart';
import 'package:islamia/presentation/widgets/error_widget.dart';
import 'package:islamia/presentation/widgets/forgot_password_dialog.dart';
import 'package:islamia/presentation/widgets/loading_button.dart';
import 'package:islamia/presentation/widgets/social_sign_in_button.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    // Listen to auth state changes
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.isAuthenticated && !next.requiresEmailVerification) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (next.isAuthenticated && next.requiresEmailVerification) {
        Navigator.pushNamed(context, '/email-verification');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // App Logo
                _buildAppLogo(),
                
                const SizedBox(height: 48),
                
                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your Islamic journey',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Error widget
                if (authState.hasError) ...[
                  AppErrorWidget(
                    error: authState.error!,
                    canRetry: authState.canRetry,
                    onRetry: authController.retry,
                    onDismiss: authController.clearError,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'Enter your email',
                  ),
                  validator: _validateEmail,
                  enabled: !authState.isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: _validatePassword,
                  enabled: !authState.isLoading,
                  onFieldSubmitted: (_) => _signIn(),
                ),
                
                const SizedBox(height: 16),
                
                // Remember me and Forgot password
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: authState.isLoading ? null : (value) => setState(() => _rememberMe = value ?? false),
                    ),
                    const Text('Remember me'),
                    const Spacer(),
                    TextButton(
                      onPressed: authState.isLoading ? null : _showForgotPasswordDialog,
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Sign in button
                LoadingButton(
                  onPressed: _signIn,
                  isLoading: authState.isLoading,
                  child: const Text('Sign In'),
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                _buildDivider('OR CONTINUE WITH'),
                
                const SizedBox(height: 24),
                
                // Social sign in buttons
                Row(
                  children: [
                    Expanded(
                      child: SocialSignInButton(
                        onPressed: authState.isLoading ? null : () => authController.signInWithGoogle(),
                        iconPath: 'assets/icons/google.png',
                        label: 'Google',
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        borderColor: Colors.grey[300],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SocialSignInButton(
                        onPressed: authState.isLoading ? null : (){},// => authController.signInWithApple(),
                        icon: Icons.apple,
                        label: 'Apple',
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                SocialSignInButton(
                  onPressed: authState.isLoading ? null : () => authController.signInWithFacebook(),
                  iconPath: 'assets/icons/facebook.png',
                  label: 'Continue with Facebook',
                  backgroundColor: const Color(0xFF1877F2),
                  textColor: Colors.white,
                ),
                
                const SizedBox(height: 24),
                
                // Phone sign in
                OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _navigateToPhoneSignIn,
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text('Sign in with Phone'),
                ),
                
                const SizedBox(height: 32),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: authState.isLoading ? null : _navigateToSignUp,
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Guest mode
                TextButton(
                  onPressed: authState.isLoading ? null : _continueAsGuest,
                  child: const Text('Continue as Guest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mosque,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Islamia',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _signIn() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ForgotPasswordDialog(
        initialEmail: _emailController.text.trim(),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/sign-up');
  }

  void _navigateToPhoneSignIn() {
    Navigator.pushNamed(context, '/phone-sign-in');
  }

  void _continueAsGuest() {
    Navigator.pushReplacementNamed(context, '/home');
  }
}
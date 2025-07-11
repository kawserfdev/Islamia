import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/user/user_provider.dart';

class SocialAuthButtons extends ConsumerWidget {
  const SocialAuthButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    
    return Column(
      children: [
        // Google Sign In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authState.isLoading 
                ? null 
                : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
            icon: Image.asset(
              'assets/images/google_logo.png',
              width: 20,
              height: 20,
            ),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Phone Sign In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authState.isLoading 
                ? null 
                : () => _showPhoneSignInDialog(context, ref),
            icon: const Icon(Icons.phone),
            label: const Text('Continue with Phone'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Biometric Sign In (if available)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authState.isLoading 
                ? null 
                : () => ref.read(authNotifierProvider.notifier).signInWithBiometrics(),
            icon: const Icon(Icons.fingerprint),
            label: const Text('Use Biometric'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPhoneSignInDialog(BuildContext context, WidgetRef ref) {
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phone Sign In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your phone number to receive a verification code.'),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1234567890',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier)
                  .signInWithPhone(phoneController.text.trim());
            },
            child: const Text('Send Code'),
          ),
        ],
      ),
    );
  }
}
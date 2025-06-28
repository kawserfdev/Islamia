import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/auth_provider.dart';
import 'loading_button.dart';
import 'error_widget.dart';

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  final String? initialEmail;

  const ForgotPasswordDialog({
    Key? key,
    this.initialEmail,
  }) : super(key: key);

  @override
  ConsumerState<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return AlertDialog(
      title: Text(_isEmailSent ? 'Email Sent!' : 'Reset Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isEmailSent) ...[
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Password reset instructions have been sent to ${_emailController.text}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your email and follow the instructions to reset your password.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Text(
                'Enter your email address and we\'ll send you instructions to reset your password.',
              ),
              const SizedBox(height: 16),
              
              // Error widget
              if (authState.hasError) ...[
                AppErrorWidget(
                  error: authState.error!,
                  canRetry: authState.canRetry,
                  onRetry: authController.retry,
                  onDismiss: authController.clearError,
                  showDismiss: false,
                ),
                const SizedBox(height: 16),
              ],
              
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                enabled: !authState.isLoading,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_isEmailSent ? 'Close' : 'Cancel'),
        ),
        if (!_isEmailSent)
          LoadingButton(
            onPressed: _sendResetEmail,
            isLoading: authState.isLoading,
            child: const Text('Send Reset Email'),
          ),
      ],
    );
  }

  void _sendResetEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(
        _emailController.text.trim(),
      );
      
      final authState = ref.read(authControllerProvider);
      if (!authState.hasError) {
        setState(() {
          _isEmailSent = true;
        });
      }
    }
  }
}
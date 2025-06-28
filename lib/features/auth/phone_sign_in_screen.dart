import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/auth_provider.dart';
import 'package:islamia/presentation/widgets/error_widget.dart';
import 'package:islamia/presentation/widgets/loading_button.dart';

class PhoneSignInScreen extends ConsumerStatefulWidget {
  const PhoneSignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends ConsumerState<PhoneSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  String _selectedCountryCode = '+1';
  bool _isCodeSent = false;
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;
  
  final Map<String, String> _countryCodes = {
    '+1': '🇺🇸 United States',
    '+880': '🇧🇩 Bangladesh',
    '+91': '🇮🇳 India',
    '+92': '🇵🇰 Pakistan',
    '+966': '🇸🇦 Saudi Arabia',
    '+971': '🇦🇪 UAE',
    '+44': '🇬🇧 United Kingdom',
    '+49': '🇩🇪 Germany',
    '+33': '🇫🇷 France',
    '+81': '🇯🇵 Japan',
  };

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Sign In'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Illustration
                Icon(
                  Icons.phone_android,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  _isCodeSent ? 'Verify Phone Number' : 'Enter Phone Number',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _isCodeSent 
                      ? 'Enter the 6-digit code sent to ${_selectedCountryCode} ${_phoneController.text}'
                      : 'We\'ll send you a verification code via SMS',
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
                    onRetry: () => ref.read(authControllerProvider.notifier).retry(),
                    onDismiss: () => ref.read(authControllerProvider.notifier).clearError(),
                  ),
                  const SizedBox(height: 16),
                ],
                
                if (!_isCodeSent) ...[
                  // Country code and phone number
                  Row(
                    children: [
                      // Country code dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            items: _countryCodes.entries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.key),
                              );
                            }).toList(),
                            onChanged: _isLoading ? null : (value) {
                              setState(() {
                                _selectedCountryCode = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Phone number field
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '1234567890',
                          ),
                          validator: _validatePhoneNumber,
                          enabled: !_isLoading,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                       // Send code button
                  LoadingButton(
                    onPressed: _sendCode,
                    isLoading: _isLoading,
                    child: const Text('Send Verification Code'),
                  ),
                ] else ...[
                  // Verification code input
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      hintText: '000000',
                      counterText: '',
                    ),
                    maxLength: 6,
                    validator: _validateVerificationCode,
                    enabled: !_isLoading,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      if (value.length == 6) {
                        _verifyCode();
                      }
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Verify button
                  LoadingButton(
                    onPressed: _verifyCode,
                    isLoading: _isLoading,
                    child: const Text('Verify Code'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Resend code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn't receive the code? "),
                      TextButton(
                        onPressed: _isLoading ? null : _resendCode,
                        child: const Text('Resend'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Change phone number
                  TextButton(
                    onPressed: _isLoading ? null : _changePhoneNumber,
                    child: const Text('Change Phone Number'),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Standard messaging rates may apply. Your phone number will be used for account verification only.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateVerificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the verification code';
    }
    if (value.length != 6) {
      return 'Verification code must be 6 digits';
    }
    return null;
  }

  void _sendCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
      
      try {
        await ref.read(authServiceProvider).signInWithPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (credential) async {
            // Auto-verification completed
            setState(() {
              _isLoading = false;
            });
            
            final result = await ref.read(authServiceProvider).verifyPhoneNumberWithCode(
              verificationId: _verificationId!,
              smsCode: credential.smsCode ?? '',
            );
            
            if (result.isNewUser) {
              Navigator.pushReplacementNamed(context, '/complete-profile');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          verificationFailed: (error) {
            setState(() {
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification failed: ${error.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          codeSent: (verificationId, resendToken) {
            setState(() {
              _isLoading = false;
              _isCodeSent = true;
              _verificationId = verificationId;
              _resendToken = resendToken;
            });
          },
          codeAutoRetrievalTimeout: (verificationId) {
            setState(() {
              _verificationId = verificationId;
            });
          },
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _verifyCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_verificationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification ID not found. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final result = await ref.read(authServiceProvider).verifyPhoneNumberWithCode(
          verificationId: _verificationId!,
          smsCode: _codeController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (result.isNewUser) {
          Navigator.pushReplacementNamed(context, '/complete-profile');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resendCode() {
    _codeController.clear();
    _sendCode();
  }

  void _changePhoneNumber() {
    setState(() {
      _isCodeSent = false;
      _verificationId = null;
      _resendToken = null;
      _codeController.clear();
    });
  }
}
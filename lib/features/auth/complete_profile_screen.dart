import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/auth_provider.dart';
import 'package:islamia/core/providers/user_profile_provider.dart';
import 'package:islamia/data/models/user/user_profile.dart';
import 'package:islamia/presentation/widgets/error_widget.dart';
import 'package:islamia/presentation/widgets/loading_button.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _popularCountries = [
    'United States',
    'Bangladesh',
    'India',
    'Pakistan',
    'Saudi Arabia',
    'United Arab Emirates',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final authState = ref.watch(authControllerProvider);
    final userProfileState = ref.watch(userProfileControllerProvider);
    final userProfileController = ref.read(userProfileControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: 0.8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Welcome message
                Text(
                  'Almost Done!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Please complete your profile to personalize your Islamic journey',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Error widget
                if (userProfileState.hasError) ...[
                  AppErrorWidget(
                    error: userProfileState.error!,
                    canRetry: userProfileState.canRetry,
                    onRetry: userProfileController.retry,
                    onDismiss: userProfileController.clearError,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'Enter your first name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  enabled: !userProfileState.isUpdating,
                ),
                
                const SizedBox(height: 16),
                
                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'Enter your last name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  enabled: !userProfileState.isUpdating,
                ),
                
                const SizedBox(height: 16),
                
                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  items: _genderOptions.map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: userProfileState.isUpdating ? null : (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Date of Birth
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    hintText: 'Select your date of birth',
                  ),
                  
                  controller: TextEditingController(
                    text: _selectedDateOfBirth != null
                        ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                        : '',
                  ),
                  onTap: userProfileState.isUpdating ? null : _selectDateOfBirth,
                  validator: (value) {
                    if (_selectedDateOfBirth == null) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Country
                TextFormField(
                  controller: _countryController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Country',
                    prefixIcon: const Icon(Icons.public_outlined),
                    hintText: 'Enter your country',
                    suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (country) {
                        _countryController.text = country;
                      },
                      itemBuilder: (context) {
                        return _popularCountries.map((country) {
                          return PopupMenuItem<String>(
                            value: country,
                            child: Text(country),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your country';
                    }
                    return null;
                  },
                  enabled: !userProfileState.isUpdating,
                ),
                
                const SizedBox(height: 16),
                
                // City
                TextFormField(
                  controller: _cityController,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city_outlined),
                    hintText: 'Enter your city',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                  enabled: !userProfileState.isUpdating,
                ),
                
                const SizedBox(height: 32),
                
                // Complete Profile button
                LoadingButton(
                  onPressed: _completeProfile,
                  isLoading: userProfileState.isUpdating,
                  child: const Text('Complete Profile'),
                ),
                
                const SizedBox(height: 16),
                
                // Skip for now
                TextButton(
                  onPressed: userProfileState.isUpdating ? null : _skipForNow,
                  child: const Text('Skip for Now'),
                ),
                
                const SizedBox(height: 24),
                
                // Privacy note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your personal information is kept private and secure. We use this information to personalize your Islamic experience.',
                          style: TextStyle(
                            color: Colors.green[700],
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

  void _selectDateOfBirth() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100);
    final lastDate = DateTime(now.year - 13); // Minimum age 13

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(now.year - 25),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Date of Birth',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
      });
    }
  }

  void _completeProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = ref.read(authControllerProvider);
      if (authState.firebaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please sign in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final profile = UserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _selectedGender?.toLowerCase(),
        dateOfBirth: _selectedDateOfBirth,
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        timeZone: DateTime.now().timeZoneName,
      );

      await ref.read(userProfileControllerProvider.notifier).updateUserProfile(
        authState.firebaseUser!.uid,
        profile,
      );

      final userProfileState = ref.read(userProfileControllerProvider);
      if (!userProfileState.hasError) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  void _skipForNow() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Profile Setup?'),
        content: const Text(
          'You can complete your profile later from the settings. Some features may be limited without a complete profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
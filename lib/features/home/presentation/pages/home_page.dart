import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/auth_provider.dart';
import 'package:islamia/data/models/user/user_model.dart';
import 'package:islamia/features/quran/presentation/pages/quran_page.dart'; // Import QuranPage
import 'package:islamia/features/prayer_times/presentation/pages/prayer_times_page.dart'; // Import PrayerTimesPage

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Islamia - Home'),
//       ),
//       body: ListView(
//         children: <Widget>[
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             color: Colors.lightGreen[100],
//             child: const Center(
//               child: Text('Islamic Greeting Placeholder'),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             color: Colors.lime[100],
//             child: const Center(
//               child: Text('Hijri Date Placeholder'),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             color: Colors.teal[100],
//             child: const Center(
//               child: Text('Next Prayer Countdown Placeholder'),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             color: Colors.cyan[100],
//             child: Center(
//               child: Column( // Changed to Column to hold multiple buttons
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const QuranPage()),
//                       );
//                     },
//                     child: const Text('Read Quran'),
//                   ),
//                   const SizedBox(height: 10), // Spacing between buttons
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const PrayerTimesPage()),
//                       );
//                     },
//                     child: const Text('View Prayer Times'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             color: Colors.blue[100],
//             child: const Center(
//               child: Text('Daily Quran Verse Placeholder'),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             color: Colors.indigo[100],
//             child: const Center(
//               child: Text('Daily Hadith Placeholder'),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             color: Colors.purple[100],
//             child: const Center(
//               child: Text('Prayer Times Overview Placeholder'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    if (!authState.isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view profile'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => _showSignOutDialog(context, ref),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) => _buildProfileContent(context, user, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading profile: $error'),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel? user, WidgetRef ref) {
    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 60,
            backgroundImage: user.photoURL != null 
                ? NetworkImage(user.photoURL!) 
                : null,
            child: user.photoURL == null 
                ? const Icon(Icons.person, size: 60) 
                : null,
          ),
          
          const SizedBox(height: 16),
          
          // User Info
          Text(
            user.displayText,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          
          if (user.email != null) ...[
            const SizedBox(height: 8),
            Text(
              user.email!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          
          if (user.phoneNumber != null) ...[
            const SizedBox(height: 8),
            Text(
              user.phoneNumber!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Settings Cards
          _buildSettingsCard(
            context,
            title: 'Preferences',
            subtitle: 'Language, Theme, Notifications',
            icon: Icons.settings,
            onTap: () => _navigateToPreferences(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsCard(
            context,
            title: 'Prayer Settings',
            subtitle: 'Times, Notifications, Method',
            icon: Icons.access_time,
            onTap: () => _navigateToPrayerSettings(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsCard(
            context,
            title: 'Account Settings',
            subtitle: 'Security, Privacy, Data',
            icon: Icons.account_circle,
            onTap: () => _navigateToAccountSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _navigateToPreferences(BuildContext context) {
    // Navigate to preferences screen
    print('Navigate to preferences');
  }

  void _navigateToPrayerSettings(BuildContext context) {
    // Navigate to prayer settings screen
    print('Navigate to prayer settings');
  }

  void _navigateToAccountSettings(BuildContext context) {
    // Navigate to account settings screen
    print('Navigate to account settings');
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
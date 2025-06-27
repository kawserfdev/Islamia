// import 'package:flutter/material.dart';
// import 'package:islamia/features/quran/presentation/pages/quran_page.dart'; // Import QuranPage
// import 'package:islamia/features/prayer_times/presentation/pages/prayer_times_page.dart'; // Import PrayerTimesPage

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





import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/user_profile_provider.dart';
import 'package:islamia/data/models/user/user_model.dart';

// Example: Profile Screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(userProfileControllerProvider);
    final userProfileController = ref.read(userProfileControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userProfileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProfileState.error != null
              ? Center(child: Text('Error: ${userProfileState.error}'))
              : _buildProfileContent(context, userProfileState.user, userProfileController),
    );
  }

  Widget _buildProfileContent(
    BuildContext context, 
    UserModel? user, 
    UserProfileController controller,
  ) {
    if (user == null) return const Center(child: Text('No user data'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 50,
            backgroundImage: user.photoURL != null 
                ? NetworkImage(user.photoURL!) 
                : null,
            child: user.photoURL == null 
                ? const Icon(Icons.person, size: 50) 
                : null,
          ),
          const SizedBox(height: 16),
          
          // User Info
          Text(
            user.displayName ?? 'No Name',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            user.email ?? 'No Email',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 24),
          
          // Edit Profile Button
          ElevatedButton(
            onPressed: () => _showEditDialog(context, user, controller),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    UserModel user,
    UserProfileController controller,
  ) {
    final nameController = TextEditingController(text: user.displayName);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
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
              final updatedUser = user.copyWith(
                displayName: nameController.text,
                email: emailController.text,
              );
              controller.updateUser(updatedUser);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
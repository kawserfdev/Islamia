import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/statistics_card.dart';
import '../../widgets/profile/achievements_section.dart';
import '../../widgets/profile/quick_actions.dart';

class ProfileDashboardScreen extends ConsumerWidget {
  const ProfileDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          
          return CustomScrollView(
            slivers: [
              // App Bar with profile header
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileHeader(user: user),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(context, ref, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit_profile',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit Profile'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'backup',
                        child: ListTile(
                          leading: Icon(Icons.backup),
                          title: Text('Backup Data'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: ListTile(
                          leading: Icon(Icons.download),
                          title: Text('Export Data'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'sign_out',
                        child: ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Sign Out'),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: QuickActions(userId: user.id),
                ),
              ),

              // Statistics Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StatisticsCard(
                    statistics: user.statistics,
                    userId: user.id,
                  ),
                ),
              ),

              // Achievements Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AchievementsSection(
                    userId: user.id,
                    recentAchievements: user.statistics.recentAchievements,
                  ),
                ),
              ),

              // Recent Activity (placeholder)
              SliverToBoxAdapter(
                child: _buildRecentActivity(context, theme),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Navigate to full activity log
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildActivityItem(
                context,
                'Prayer Logged',
                'Maghrib prayer completed on time',
                Icons.check_circle,
                Colors.green,
                '2 hours ago',
              ),
              _buildActivityItem(
                context,
                'Quran Reading',
                'Completed Surah Al-Fatiha',
                Icons.menu_book,
                Colors.blue,
                '5 hours ago',
              ),
              _buildActivityItem(
                context,
                'Achievement Unlocked',
                'First Week Streak',
                Icons.star,
                Colors.amber,
                '1 day ago',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit_profile':
        Navigator.pushNamed(context, '/edit-profile');
        break;
      case 'backup':
        _showBackupDialog(context, ref);
        break;
      case 'export':
        _exportUserData(context, ref);
        break;
      case 'sign_out':
        _showSignOutDialog(context, ref);
        break;
    }
  }

  void _showBackupDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text(
          'Create a backup of your Islamic app data including prayer logs, reading progress, and achievements?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final user = ref.read(currentUserProfileProvider).value;
              if (user != null) {
                await ref.read(backupProvider.notifier).createBackup(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup created successfully')),
                  );
                }
              }
            },
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _exportUserData(BuildContext context, WidgetRef ref) {
    // Implementation for data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon!')),
    );
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
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
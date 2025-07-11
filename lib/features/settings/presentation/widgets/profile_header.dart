import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:islamia/data/models/user/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile user;

  const ProfileHeader({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: user.photoURL != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.photoURL!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          errorWidget: (context, url, error) => Text(
                            user.initials,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Name and verification
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Email or phone
          Text(
            user.email ?? user.phoneNumber ?? 'No contact info',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Prayer Streak',
                '${user.statistics.prayerStats.currentPrayerStreak}',
                Icons.local_fire_department,
              ),
              _buildStatItem(
                'Total Points',
                '${user.statistics.totalPoints}',
                Icons.star,
              ),
              _buildStatItem(
                'Achievements',
                '${user.achievements.length}',
                Icons.emoji_events,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:islamia/data/models/user/user_statistics.dart';

class StatisticsCard extends StatelessWidget {
  final UserStatistics statistics;
  final String userId;

  const StatisticsCard({
    Key? key,
    required this.statistics,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Islamic Journey',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to detailed statistics
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Prayer Statistics
            _buildStatSection(
              context,
              'Prayer Statistics',
              [
                _StatItem('Total Prayers', '${statistics.prayerStats.totalPrayers}'),
                _StatItem('On Time', '${statistics.prayerStats.onTimePercentage.toStringAsFixed(1)}%'),
                _StatItem('Current Streak', '${statistics.prayerStats.currentPrayerStreak} days'),
              ],
              Icons.access_time,
              Colors.green,
            ),
            
            const SizedBox(height: 16),
            
            // Reading Statistics
            _buildStatSection(
              context,
              'Reading Progress',
              [
                _StatItem('Quran Progress', '${statistics.readingStats.quranCompletionPercentage.toStringAsFixed(1)}%'),
                _StatItem('Completed Surahs', '${statistics.readingStats.completedSurahs}/114'),
                _StatItem('Reading Streak', '${statistics.readingStats.currentReadingStreak} days'),
              ],
              Icons.menu_book,
              Colors.blue,
            ),
            
            const SizedBox(height: 16),
            
            // Overall Progress
            _buildProgressBar(
              context,
              'Overall Islamic Practice',
              _calculateOverallProgress(),
              theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection(
    BuildContext context,
    String title,
    List<_StatItem> items,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items.map((item) => Expanded(
            child: Column(
              children: [
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String title,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  double _calculateOverallProgress() {
    // Simple calculation - you can make this more sophisticated
    final prayerProgress = statistics.prayerStats.onTimePercentage / 100;
    final readingProgress = statistics.readingStats.quranCompletionPercentage / 100;
    
    return (prayerProgress + readingProgress) / 2;
  }
}

class _StatItem {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);
}


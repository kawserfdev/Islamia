import 'package:flutter/material.dart';
import 'package:islamia/features/hadith/pages/hadith_collections_screen.dart';
import 'package:islamia/features/quran/pages/surah_list_page.dart';
import '../../core/constants/app_constants.dart';

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quickAccessItems = [
      QuickAccessItem(
        icon: Icons.menu_book,
        title: 'Quran',
        subtitle: 'Read & Listen',
        color: Colors.green,
        onTap: () => _navigateToQuran(context),
      ),
      QuickAccessItem(
        icon: Icons.library_books,
        title: 'Hadith',
        subtitle: 'Prophetic Traditions',
        color: Colors.blue,
        onTap: () => _navigateToHadith(context),
      ),
      QuickAccessItem(
        icon: Icons.explore,
        title: 'Qibla',
        subtitle: 'Direction Finder',
        color: Colors.orange,
        onTap: () => _navigateToQibla(context),
      ),
      QuickAccessItem(
        icon: Icons.mosque,
        title: 'Mosques',
        subtitle: 'Find Nearby',
        color: Colors.purple,
        onTap: () => _navigateToMosques(context),
      ),
      QuickAccessItem(
        icon: Icons.calendar_today,
        title: 'Calendar',
        subtitle: 'Islamic Dates',
        color: Colors.red,
        onTap: () => _navigateToCalendar(context),
      ),
      QuickAccessItem(
        icon: Icons.favorite,
        title: 'Duas',
        subtitle: 'Daily Prayers',
        color: Colors.pink,
        onTap: () => _navigateToDuas(context),
      ),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppConstants.quickAccessColumns,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 164,
            ),
            itemCount: quickAccessItems.length,
            itemBuilder: (context, index) {
              final item = quickAccessItems[index];
              return _buildQuickAccessCard(context, item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, QuickAccessItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 32, color: item.color),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuran(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Navigating to Quran...')))
        .closed;
    // Navigate to Quran screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SurahListScreen()),
    );
  }

  void _navigateToHadith(BuildContext context) {
    // Navigate to Hadith screen
    
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigating to Hadith...'))).closed;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HadithCollectionsScreen()),
    );
  }

  void _navigateToQibla(BuildContext context) {
    // Navigate to Qibla screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigating to Qibla...')));
  }

  void _navigateToMosques(BuildContext context) {
    // Navigate to Mosques screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigating to Mosques...')));
  }

  void _navigateToCalendar(BuildContext context) {
    // Navigate to Calendar screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigating to Calendar...')));
  }

  void _navigateToDuas(BuildContext context) {
    // Navigate to Duas screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigating to Duas...')));
  }
}

class QuickAccessItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const QuickAccessItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

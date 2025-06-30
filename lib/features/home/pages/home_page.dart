import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/presentation/providers/daily_content_provider.dart';
import 'package:islamia/presentation/providers/prayer_provider.dart';
import 'package:islamia/presentation/widgets/daily_hadith_card.dart';
import 'package:islamia/presentation/widgets/daily_verse_card.dart';
import 'package:islamia/presentation/widgets/greeting_card.dart';
import 'package:islamia/presentation/widgets/islamic_app_bar.dart';
import 'package:islamia/presentation/widgets/prayer_time_card.dart';
import 'package:islamia/presentation/widgets/quick_access_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const IslamicAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all providers
          ref.refresh(dailyVerseProvider);
          ref.refresh(dailyHadithProvider);
          ref.refresh(islamicDateProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Card
              const GreetingCard(),
              
              // Prayer Time Card
              const PrayerTimeCard(),
              
              const SizedBox(height: 24),
              
              // Quick Access Grid
              const QuickAccessGrid(),
              
              const SizedBox(height: 24),
              
              // Daily Content Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Daily Content',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Daily Verse Card
              const DailyVerseCard(),
              
              // Daily Hadith Card
              const DailyHadithCard(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
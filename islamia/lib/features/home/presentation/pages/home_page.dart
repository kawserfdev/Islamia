import 'package:flutter/material.dart';
import 'package:islamia/features/quran/presentation/pages/quran_page.dart'; // Import QuranPage
import 'package:islamia/features/prayer_times/presentation/pages/prayer_times_page.dart'; // Import PrayerTimesPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamia - Home'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.lightGreen[100],
            child: const Center(
              child: Text('Islamic Greeting Placeholder'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.lime[100],
            child: const Center(
              child: Text('Hijri Date Placeholder'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.teal[100],
            child: const Center(
              child: Text('Next Prayer Countdown Placeholder'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.cyan[100],
            child: Center(
              child: Column( // Changed to Column to hold multiple buttons
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QuranPage()),
                      );
                    },
                    child: const Text('Read Quran'),
                  ),
                  const SizedBox(height: 10), // Spacing between buttons
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrayerTimesPage()),
                      );
                    },
                    child: const Text('View Prayer Times'),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue[100],
            child: const Center(
              child: Text('Daily Quran Verse Placeholder'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.indigo[100],
            child: const Center(
              child: Text('Daily Hadith Placeholder'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.purple[100],
            child: const Center(
              child: Text('Prayer Times Overview Placeholder'),
            ),
          ),
        ],
      ),
    );
  }
}

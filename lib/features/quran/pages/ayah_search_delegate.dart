import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/search_provider.dart';
import 'package:islamia/data/models/quran/ayah_model.dart';

class AyahSearchDelegate extends SearchDelegate<AyahModel?> {
  final int? surahNumber;
  final int? juzNumber;
  final WidgetRef ref;

  AyahSearchDelegate({
    this.surahNumber,
    this.juzNumber,
    required this.ref,
  });

  @override
  String get searchFieldLabel => 'Search Ayahs...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter search terms to find Ayahs'),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final searchResultsAsync = ref.watch(ayahSearchProvider(SearchQuery(
          query: query,
          surahNumber: surahNumber,
          juzNumber: juzNumber,
        )));

        return searchResultsAsync.when(
          data: (results) => results.isEmpty
              ? const Center(child: Text('No results found'))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final ayah = results[index];
                    return _buildSearchResultTile(context, ayah);
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search by Arabic text'),
            onTap: () {
              query = 'بِسْمِ اللَّهِ';
              showResults(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search by translation'),
            onTap: () {
              query = 'Allah';
              showResults(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search by transliteration'),
            onTap: () {
              query = 'bismillah';
              showResults(context);
            },
          ),
        ],
      );
    }

    return buildResults(context);
  }

  Widget _buildSearchResultTile(BuildContext context, AyahModel ayah) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          ayah.text,
          style: const TextStyle(
            fontFamily: 'Noto Naskh Arabic',
            fontSize: 18,
            height: 1.8,
          ),
          textDirection: TextDirection.rtl,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ayah.translations['en'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Surah ${ayah.surahNumber}, Ayah ${ayah.ayahNumber}',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () {
          close(context, ayah);
        },
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
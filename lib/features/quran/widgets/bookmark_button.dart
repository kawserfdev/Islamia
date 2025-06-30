import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/bookmark_notifier.dart';
import 'package:islamia/data/models/quran/bookmark_model.dart';

class BookmarkButton extends ConsumerWidget {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String ayahText;

  const BookmarkButton({
    Key? key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.ayahText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(isAyahBookmarked(
      AyahReference(surahNumber: surahNumber, ayahNumber: ayahNumber)
    ));
    
    final bookmarkNotifier = ref.read(bookmarkNotifierProvider.notifier);

    return IconButton(
      onPressed: () async {
        if (isBookmarked) {
          await bookmarkNotifier.removeBookmarkByAyah(surahNumber, ayahNumber);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark removed')),
          );
        } else {
          final bookmark = BookmarkModel(
            id: '',
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            surahName: surahName,
            ayahText: ayahText,
            createdAt: DateTime.now(),
          );
          
          await bookmarkNotifier.addBookmark(bookmark);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark added')),
          );
        }
      },
      icon: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: isBookmarked ? Colors.amber : null,
      ),
    );
  }
}
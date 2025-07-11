import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/calendar_provider.dart';

class CalendarHeader extends ConsumerWidget {
  const CalendarHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarStateProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatGregorianDate(calendarState.selectedDate),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer(
                  builder: (context, ref, child) {
                    final hijriDate = ref.watch(selectedHijriDateProvider);
                    return hijriDate.when(
                      data: (hijri) => Text(
                        hijri.formattedDate,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      loading: () => Text(
                        'Loading...',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => ref.read(calendarStateProvider.notifier).goToPreviousMonth(),
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              IconButton(
                onPressed: () => ref.read(calendarStateProvider.notifier).goToNextMonth(),
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatGregorianDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.year}';
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/utils/app_utils.dart';

final greetingProvider = Provider<Map<String, String>>((ref) {
  return IslamicUtils.getTimeBasedGreeting();
});

final currentTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

class DhikrBead {
  final int number;
  final DateTime timestamp;
  final bool isCompleted;

  const DhikrBead({
    required this.number,
    required this.timestamp,
    this.isCompleted = false,
  });

  factory DhikrBead.fromJson(Map<String, dynamic> json) {
    return DhikrBead(
      number: json['number'],
      timestamp: DateTime.parse(json['timestamp']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'timestamp': timestamp.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}

enum DuaCategory {
  daily,
  prayer,
  protection,
  forgiveness,
  guidance,
  health,
  travel,
  food,
  sleep,
  morning,
  evening,
  special;

  String get displayName {
    switch (this) {
      case DuaCategory.daily:
        return 'Daily Duas';
      case DuaCategory.prayer:
        return 'Prayer Duas';
      case DuaCategory.protection:
        return 'Protection';
      case DuaCategory.forgiveness:
        return 'Forgiveness';
      case DuaCategory.guidance:
        return 'Guidance';
      case DuaCategory.health:
        return 'Health';
      case DuaCategory.travel:
        return 'Travel';
      case DuaCategory.food:
        return 'Food';
      case DuaCategory.sleep:
        return 'Sleep';
      case DuaCategory.morning:
        return 'Morning';
      case DuaCategory.evening:
        return 'Evening';
      case DuaCategory.special:
        return 'Special Occasions';
    }
  }
}

enum DuaOccasion {
  daily,
  afterPrayer,
  beforeMeals,
  afterMeals,
  beforeSleep,
  afterWaking,
  travel,
  difficulties,
  illness,
  friday,
  ramadan,
  hajj,
  anyTime;

  String get displayName {
    switch (this) {
      case DuaOccasion.daily:
        return 'Daily';
      case DuaOccasion.afterPrayer:
        return 'After Prayer';
      case DuaOccasion.beforeMeals:
        return 'Before Meals';
      case DuaOccasion.afterMeals:
        return 'After Meals';
      case DuaOccasion.beforeSleep:
        return 'Before Sleep';
      case DuaOccasion.afterWaking:
        return 'After Waking';
      case DuaOccasion.travel:
        return 'Travel';
      case DuaOccasion.difficulties:
        return 'Difficulties';
      case DuaOccasion.illness:
        return 'Illness';
      case DuaOccasion.friday:
        return 'Friday';
      case DuaOccasion.ramadan:
        return 'Ramadan';
      case DuaOccasion.hajj:
        return 'Hajj';
      case DuaOccasion.anyTime:
        return 'Any Time';
    }
  }
}

enum ReminderFrequency {
  daily,
  weekly,
  monthly,
  custom;

  String get displayName {
    switch (this) {
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.monthly:
        return 'Monthly';
      case ReminderFrequency.custom:
        return 'Custom';
    }
  }
}
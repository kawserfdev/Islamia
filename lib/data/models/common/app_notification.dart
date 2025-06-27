class AppNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime scheduledTime;
  final bool isRead;
  final bool isDelivered;
  final NotificationType type;
  final NotificationPriority priority;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data = const {},
    required this.scheduledTime,
    this.isRead = false,
    this.isDelivered = false,
    required this.type,
    this.priority = NotificationPriority.normal,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      imageUrl: json['imageUrl'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      scheduledTime: DateTime.parse(json['scheduledTime']),
      isRead: json['isRead'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isRead': isRead,
      'isDelivered': isDelivered,
      'type': type.name,
      'priority': priority.name,
    };
  }
}

enum NotificationType {
  prayer,
  dua,
  hadith,
  quran,
  event,
  reminder,
  general;

  String get displayName {
    switch (this) {
      case NotificationType.prayer:
        return 'Prayer';
      case NotificationType.dua:
        return 'Dua';
      case NotificationType.hadith:
        return 'Hadith';
      case NotificationType.quran:
        return 'Quran';
      case NotificationType.event:
        return 'Event';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.general:
        return 'General';
    }
  }
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }
}
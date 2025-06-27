class SyncStatus {
  final String id;
  final String dataType;
  final DateTime lastSyncTime;
  final SyncState state;
  final String? error;
  final int? totalItems;
  final int? syncedItems;
  final DateTime? nextSyncTime;

  const SyncStatus({
    required this.id,
    required this.dataType,
    required this.lastSyncTime,
    required this.state,
    this.error,
    this.totalItems,
    this.syncedItems,
    this.nextSyncTime,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      id: json['id'],
      dataType: json['dataType'],
      lastSyncTime: DateTime.parse(json['lastSyncTime']),
      state: SyncState.values.firstWhere((e) => e.name == json['state']),
      error: json['error'],
      totalItems: json['totalItems'],
      syncedItems: json['syncedItems'],
      nextSyncTime: json['nextSyncTime'] != null ? DateTime.parse(json['nextSyncTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataType': dataType,
      'lastSyncTime': lastSyncTime.toIso8601String(),
      'state': state.name,
      'error': error,
      'totalItems': totalItems,
      'syncedItems': syncedItems,
      'nextSyncTime': nextSyncTime?.toIso8601String(),
    };
  }

  double? get progress {
    if (totalItems == null || syncedItems == null) return null;
    return totalItems! > 0 ? syncedItems! / totalItems! : 0.0;
  }
}

enum SyncState {
  idle,
  syncing,
  completed,
  failed,
  paused;

  String get displayName {
    switch (this) {
      case SyncState.idle:
        return 'Idle';
      case SyncState.syncing:
        return 'Syncing';
      case SyncState.completed:
        return 'Completed';
      case SyncState.failed:
        return 'Failed';
      case SyncState.paused:
        return 'Paused';
    }
  }
}
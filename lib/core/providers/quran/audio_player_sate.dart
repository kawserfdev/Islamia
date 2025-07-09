enum RepeatMode { none, single, all }

class AudioPlayerState {
  final int? currentAyah;
  final int? surahNumber;
  final Duration position;
  final Duration duration;
  final double progress;
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final bool isInitialized;
  final RepeatMode repeatMode;

  const AudioPlayerState({
    this.currentAyah,
    this.surahNumber,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.progress = 0,
    this.isPlaying = false,
    this.isPaused = false,
    this.isLoading = false,
    this.isInitialized = false,
    this.repeatMode = RepeatMode.none,
  });

  AudioPlayerState copyWith({
    int? currentAyah,
    int? surahNumber,
    Duration? position,
    Duration? duration,
    double? progress,
    bool? isPlaying,
    bool? isPaused,
    bool? isLoading,
    bool? isInitialized,
    RepeatMode? repeatMode,
  }) {
    return AudioPlayerState(
      currentAyah: currentAyah ?? this.currentAyah,
      surahNumber: surahNumber ?? this.surahNumber,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}

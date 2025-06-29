import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AudioStatus { stopped, playing, paused, loading, error }

enum RepeatMode { none, single, all }

class AudioPlayerState {
  final AudioStatus playerState;
  final Duration duration;
  final Duration position;
  final RepeatMode repeatMode;
  final int? currentSurah;
  final int? currentAyah;
  final double volume;
  final String? errorMessage;
  final bool isBuffering;

  const AudioPlayerState({
    this.playerState = AudioStatus.stopped,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.repeatMode = RepeatMode.none,
    this.currentSurah,
    this.currentAyah,
    this.volume = 1.0,
    this.errorMessage,
    this.isBuffering = false,
  });

  AudioPlayerState copyWith({
    AudioStatus? playerState,
    Duration? duration,
    Duration? position,
    RepeatMode? repeatMode,
    int? currentSurah,
    int? currentAyah,
    double? volume,
    String? errorMessage,
    bool? isBuffering,
  }) {
    return AudioPlayerState(
      playerState: playerState ?? this.playerState,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      repeatMode: repeatMode ?? this.repeatMode,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      volume: volume ?? this.volume,
      errorMessage: errorMessage ?? this.errorMessage,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }

  bool get isPlaying => playerState == AudioStatus.playing;
  bool get isPaused => playerState == AudioStatus.paused;
  bool get isLoading => playerState == AudioStatus.loading;
  bool get hasError => playerState == AudioStatus.error;
  bool get isStopped => playerState == AudioStatus.stopped;

  double get progress {
    if (duration.inMilliseconds > 0) {
      return position.inMilliseconds / duration.inMilliseconds;
    }
    return 0.0;
  }

  String get formattedPosition => _formatDuration(position);
  String get formattedDuration => _formatDuration(duration);

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class AudioService extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentUrl;

  AudioService() : super(const AudioPlayerState()) {
    _initializePlayer();
  }

  void _initializePlayer() {
    _audioPlayer.onPlayerStateChanged.listen((playerState) {
      AudioStatus newState;
      switch (playerState) {
        case PlayerState.playing:
          newState = AudioStatus.playing;
          break;
        case PlayerState.paused:
          newState = AudioStatus.paused;
          break;
        case PlayerState.stopped:
          newState = AudioStatus.stopped;
          break;
        case PlayerState.completed:
          newState = AudioStatus.stopped;
          _onAudioCompleted();
          break;
        default:
          newState = AudioStatus.stopped;
      }

      state = state.copyWith(playerState: newState, isBuffering: false);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      state = state.copyWith(position: position);
    });
  }

  Future<void> playAyah(
    String audioUrl,
    int surahNumber,
    int ayahNumber,
  ) async {
    try {
      state = state.copyWith(
        playerState: AudioStatus.loading,
        currentSurah: surahNumber,
        currentAyah: ayahNumber,
        errorMessage: null,
        isBuffering: true,
      );

      _currentUrl = audioUrl;
      await _audioPlayer.play(UrlSource(audioUrl));

      state = state.copyWith(
        playerState: AudioStatus.playing,
        isBuffering: false,
      );
    } catch (e) {
      state = state.copyWith(
        playerState: AudioStatus.error,
        errorMessage: 'Failed to play audio: $e',
        isBuffering: false,
      );
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      state = state.copyWith(
        playerState: AudioStatus.error,
        errorMessage: 'Failed to pause: $e',
      );
    }
  }

  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      state = state.copyWith(
        playerState: AudioStatus.error,
        errorMessage: 'Failed to resume: $e',
      );
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      state = state.copyWith(
        playerState: AudioStatus.stopped,
        position: Duration.zero,
        currentSurah: null,
        currentAyah: null,
      );
    } catch (e) {
      state = state.copyWith(
        playerState: AudioStatus.error,
        errorMessage: 'Failed to stop: $e',
      );
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      state = state.copyWith(
        playerState: AudioStatus.error,
        errorMessage: 'Failed to seek: $e',
      );
    }
  }

  void setRepeatMode(RepeatMode mode) {
    state = state.copyWith(repeatMode: mode);
  }

  void setVolume(double volume) {
    _audioPlayer.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  void _onAudioCompleted() {
    switch (state.repeatMode) {
      case RepeatMode.single:
        if (_currentUrl != null) {
          playAyah(_currentUrl!, state.currentSurah!, state.currentAyah!);
        }
        break;
      case RepeatMode.all:
        // Implement logic to play next ayah
        break;
      case RepeatMode.none:
        // Do nothing
        break;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

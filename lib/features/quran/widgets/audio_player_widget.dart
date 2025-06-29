import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/audio_provider.dart';
import 'package:islamia/core/services/quran/audio_service.dart';

class AudioPlayerWidget extends ConsumerWidget {
  final int surahNumber;
  final int totalAyahs;

  const AudioPlayerWidget({
    Key? key,
    required this.surahNumber,
    required this.totalAyahs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioServiceProvider);
    final audioService = ref.read(audioServiceProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.green[700],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Bar
          if (audioState.isPlaying || audioState.isPaused)
            LinearProgressIndicator(
              value: audioState.progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          
          const SizedBox(height: 8),
          
          // Controls
          Row(
            children: [
              // Current Ayah Info
              if (audioState.currentAyah != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayah ${audioState.currentAyah}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatDuration(audioState.position)} / ${_formatDuration(audioState.duration)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Control Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Previous
                  IconButton(
                    onPressed: _canGoPrevious(audioState) ? () => _previousAyah(ref) : null,
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Play/Pause
                  IconButton(
                    onPressed: () => _togglePlayPause(audioService, audioState),
                    icon: Icon(
                      audioState.isLoading
                          ? Icons.hourglass_empty
                          : audioState.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  
                  // Next
                  IconButton(
                    onPressed: _canGoNext(audioState) ? () => _nextAyah(ref) : null,
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Repeat Mode
                  IconButton(
                    onPressed: () => _toggleRepeatMode(audioService, audioState),
                    icon: Icon(
                      _getRepeatIcon(audioState.repeatMode),
                      color: audioState.repeatMode == RepeatMode.none
                          ? Colors.white60
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canGoPrevious(AudioPlayerState audioState) {
    return audioState.currentAyah != null && audioState.currentAyah! > 1;
  }

  bool _canGoNext(AudioPlayerState audioState) {
    return audioState.currentAyah != null && audioState.currentAyah! < totalAyahs;
  }

  void _togglePlayPause(AudioService audioService, AudioPlayerState audioState) {
    if (audioState.isPlaying) {
      audioService.pause();
    } else if (audioState.isPaused) {
      audioService.resume();
    }
  }

  void _previousAyah(WidgetRef ref) {
    final audioState = ref.read(audioServiceProvider);
    if (audioState.currentAyah != null && audioState.currentAyah! > 1) {
      final previousAyah = audioState.currentAyah! - 1;
      final audioUrl = _getAudioUrl(surahNumber, previousAyah);
      ref.read(audioServiceProvider.notifier).playAyah(audioUrl, surahNumber, previousAyah);
    }
  }

  void _nextAyah(WidgetRef ref) {
    final audioState = ref.read(audioServiceProvider);
    if (audioState.currentAyah != null && audioState.currentAyah! < totalAyahs) {
      final nextAyah = audioState.currentAyah! + 1;
      final audioUrl = _getAudioUrl(surahNumber, nextAyah);
      ref.read(audioServiceProvider.notifier).playAyah(audioUrl, surahNumber, nextAyah);
    }
  }

  void _toggleRepeatMode(AudioService audioService, AudioPlayerState audioState) {
    RepeatMode newMode;
    switch (audioState.repeatMode) {
      case RepeatMode.none:
        newMode = RepeatMode.single;
        break;
      case RepeatMode.single:
        newMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        newMode = RepeatMode.none;
        break;
    }
    audioService.setRepeatMode(newMode);
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return Icons.repeat;
      case RepeatMode.single:
        return Icons.repeat_one;
      case RepeatMode.all:
        return Icons.repeat;
    }
  }

  String _getAudioUrl(int surahNumber, int ayahNumber) {
    // This should use the selected reciter from settings
    return 'https://api.alquran.cloud/v1/ayah/$surahNumber:$ayahNumber/ar.alafasy';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
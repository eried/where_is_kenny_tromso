import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  // Track active sound players for each sound (allow up to 5 simultaneous instances)
  final Map<String, List<AudioPlayer>> _activePlayers = {};
  final Map<String, DateTime> _lastPlayTime = {};
  static const int _maxSimultaneousSounds = 5;
  static const Duration _cooldownDuration = Duration(seconds: 1);

  AudioPlayer? _beepPlayer;
  Timer? _beepTimer;
  bool _isBeeping = false;
  double _lastDistance = double.infinity;
  bool _isPlayingBeep = false;
  DateTime _lastBeepTime = DateTime.now();

  // Cached beep sounds for different frequencies and durations
  final Map<String, Uint8List> _beepCache = {};

  // Callback when sound should auto-stop (reached Kenny)
  VoidCallback? onReachedKenny;

  AudioService() {
    _initBeepPlayer();
  }

  Future<void> _initBeepPlayer() async {
    _beepPlayer = AudioPlayer();
    _beepPlayer!.setReleaseMode(ReleaseMode.stop);
    // Set audio context to mix with other audio without interrupting
    await _beepPlayer!.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck, // Duck other audio briefly, don't interrupt
        ),
      ),
    );

    // Listen for playback completion to properly reset flag
    _beepPlayer!.onPlayerComplete.listen((_) {
      _isPlayingBeep = false;
    });

    // Pre-generate beep sounds with different durations
    // Longer beeps for slow intervals, shorter for fast
    for (final freq in [400, 500, 600, 700, 800, 900, 1000, 1100, 1200]) {
      // Standard 80ms beep for slow/medium intervals
      _beepCache['${freq}_80'] = _generateBeepWav(frequency: freq.toDouble(), durationMs: 80);
      // Short 40ms beep for fast intervals
      _beepCache['${freq}_40'] = _generateBeepWav(frequency: freq.toDouble(), durationMs: 40);
      // Very short 25ms beep for very fast intervals
      _beepCache['${freq}_25'] = _generateBeepWav(frequency: freq.toDouble(), durationMs: 25);
    }
  }

  /// Generate a simple WAV beep sound in memory
  Uint8List _generateBeepWav({
    required double frequency,
    required int durationMs,
    int sampleRate = 22050,
  }) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final samples = Int16List(numSamples);

    // Generate sine wave
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      // Apply envelope to avoid clicks
      double envelope = 1.0;
      final attackSamples = (sampleRate * 0.01).round(); // 10ms attack
      final releaseSamples = (sampleRate * 0.01).round(); // 10ms release
      if (i < attackSamples) {
        envelope = i / attackSamples;
      } else if (i > numSamples - releaseSamples) {
        envelope = (numSamples - i) / releaseSamples;
      }
      samples[i] = (math.sin(2 * math.pi * frequency * t) * 32767 * 0.5 * envelope).round();
    }

    // Create WAV file in memory
    final wavData = ByteData(44 + numSamples * 2);

    // RIFF header
    wavData.setUint8(0, 0x52); // R
    wavData.setUint8(1, 0x49); // I
    wavData.setUint8(2, 0x46); // F
    wavData.setUint8(3, 0x46); // F
    wavData.setUint32(4, 36 + numSamples * 2, Endian.little);
    wavData.setUint8(8, 0x57); // W
    wavData.setUint8(9, 0x41); // A
    wavData.setUint8(10, 0x56); // V
    wavData.setUint8(11, 0x45); // E

    // fmt chunk
    wavData.setUint8(12, 0x66); // f
    wavData.setUint8(13, 0x6D); // m
    wavData.setUint8(14, 0x74); // t
    wavData.setUint8(15, 0x20); // (space)
    wavData.setUint32(16, 16, Endian.little);
    wavData.setUint16(20, 1, Endian.little); // PCM
    wavData.setUint16(22, 1, Endian.little); // Mono
    wavData.setUint32(24, sampleRate, Endian.little);
    wavData.setUint32(28, sampleRate * 2, Endian.little);
    wavData.setUint16(32, 2, Endian.little);
    wavData.setUint16(34, 16, Endian.little);

    // data chunk
    wavData.setUint8(36, 0x64); // d
    wavData.setUint8(37, 0x61); // a
    wavData.setUint8(38, 0x74); // t
    wavData.setUint8(39, 0x61); // a
    wavData.setUint32(40, numSamples * 2, Endian.little);

    for (int i = 0; i < numSamples; i++) {
      wavData.setInt16(44 + i * 2, samples[i], Endian.little);
    }

    return wavData.buffer.asUint8List();
  }

  /// Play a sound from the soundboard - supports multiple simultaneous instances with cooldown
  Future<void> playSound(String soundId, String assetPath) async {
    // Check cooldown - prevent same sound from playing more than once per second
    final now = DateTime.now();
    final lastPlayed = _lastPlayTime[soundId];
    if (lastPlayed != null && now.difference(lastPlayed) < _cooldownDuration) {
      debugPrint('Sound $soundId is on cooldown');
      return; // Still in cooldown, ignore this play request
    }

    // Update last play time
    _lastPlayTime[soundId] = now;

    // Initialize list if needed
    _activePlayers[soundId] ??= [];

    // Clean up completed players
    _activePlayers[soundId]!.removeWhere((player) {
      if (player.state == PlayerState.completed || player.state == PlayerState.stopped) {
        player.dispose();
        return true;
      }
      return false;
    });

    // Limit simultaneous sounds
    if (_activePlayers[soundId]!.length >= _maxSimultaneousSounds) {
      // Stop and dispose oldest player
      final oldestPlayer = _activePlayers[soundId]!.removeAt(0);
      await oldestPlayer.stop();
      await oldestPlayer.dispose();
    }

    // Create new player for this sound instance
    final player = AudioPlayer();

    // Configure to mix with other audio
    await player.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none, // Don't request focus, just mix
        ),
      ),
    );

    _activePlayers[soundId]!.add(player);

    // Auto-cleanup when complete
    player.onPlayerComplete.listen((_) async {
      _activePlayers[soundId]?.remove(player);
      await player.dispose();
    });

    // Play the sound
    try {
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing sound $soundId: $e');
      _activePlayers[soundId]?.remove(player);
      await player.dispose();
    }
  }

  /// Play a sound directly from asset path
  Future<void> playSoundFromAsset(String assetPath) async {
    final player = AudioPlayer();
    try {
      // Configure to mix with other audio
      await player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );

      await player.play(AssetSource(assetPath));
      // Auto-dispose after playback
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      debugPrint('Error playing sound: $e');
      player.dispose();
    }
  }

  /// Start proximity beeping with slow progression
  void startProximityBeep(double distanceMeters) {
    if (_isBeeping) return;
    _isBeeping = true;
    _lastDistance = distanceMeters;
    _updateBeepInterval(distanceMeters);
  }

  /// Update beep frequency based on distance - SLOW progression
  void updateProximityBeep(double distanceMeters) {
    if (!_isBeeping) return;

    // Auto-stop when reached Kenny (under 5 meters)
    if (distanceMeters < 5) {
      stopProximityBeep();
      onReachedKenny?.call();
      return;
    }

    // Only update if distance changed significantly (>50m or >5%)
    final change = (_lastDistance - distanceMeters).abs();
    if (change > 50 || change > _lastDistance * 0.05) {
      _lastDistance = distanceMeters;
      _updateBeepInterval(distanceMeters);
    }
  }

  void _updateBeepInterval(double distanceMeters) {
    _beepTimer?.cancel();

    // SLOW progression beep timing:
    // >100km: Very slow (15-20 seconds between beeps)
    // 50-100km: Slow (10-15 seconds)
    // 10-50km: Moderate (5-10 seconds)
    // 5-10km: Getting faster (3-5 seconds)
    // 1-5km: Faster (1.5-3 seconds)
    // 500m-1km: Fast (0.8-1.5 seconds)
    // 100-500m: Very fast (0.4-0.8 seconds)
    // 50-100m: Rapid (0.25-0.4 seconds)
    // <50m: Crazy fast (0.1-0.25 seconds)

    int intervalMs;
    int frequencyHz;
    int beepDurationMs;

    if (distanceMeters > 100000) {
      // >100km: Very calm, 15-20 seconds
      final t = ((distanceMeters - 100000) / 100000).clamp(0.0, 1.0);
      intervalMs = 15000 + (t * 5000).round();
      frequencyHz = 400;
      beepDurationMs = 80;
    } else if (distanceMeters > 50000) {
      // 50-100km: Slow, 10-15 seconds
      final t = (distanceMeters - 50000) / 50000;
      intervalMs = 10000 + (t * 5000).round();
      frequencyHz = 450;
      beepDurationMs = 80;
    } else if (distanceMeters > 10000) {
      // 10-50km: Moderate, 5-10 seconds
      final t = (distanceMeters - 10000) / 40000;
      intervalMs = 5000 + (t * 5000).round();
      frequencyHz = 500;
      beepDurationMs = 80;
    } else if (distanceMeters > 5000) {
      // 5-10km: Getting faster, 3-5 seconds
      final t = (distanceMeters - 5000) / 5000;
      intervalMs = 3000 + (t * 2000).round();
      frequencyHz = 600;
      beepDurationMs = 80;
    } else if (distanceMeters > 1000) {
      // 1-5km: Faster, 1.5-3 seconds
      final t = (distanceMeters - 1000) / 4000;
      intervalMs = 1500 + (t * 1500).round();
      frequencyHz = 700;
      beepDurationMs = 80;
    } else if (distanceMeters > 500) {
      // 500m-1km: Fast, 0.8-1.5 seconds
      final t = (distanceMeters - 500) / 500;
      intervalMs = 800 + (t * 700).round();
      frequencyHz = 800;
      beepDurationMs = 80;
    } else if (distanceMeters > 100) {
      // 100-500m: Very fast, 0.4-0.8 seconds
      final t = (distanceMeters - 100) / 400;
      intervalMs = 400 + (t * 400).round();
      frequencyHz = 900;
      beepDurationMs = 40; // Shorter beeps
    } else if (distanceMeters > 50) {
      // 50-100m: Rapid, 0.25-0.4 seconds
      final t = (distanceMeters - 50) / 50;
      intervalMs = 250 + (t * 150).round();
      frequencyHz = 1000;
      beepDurationMs = 40; // Shorter beeps
    } else {
      // <50m: Crazy fast, 0.1-0.25 seconds (minimum 100ms to avoid glitches)
      final t = distanceMeters / 50;
      intervalMs = 100 + (t * 150).round();
      frequencyHz = 1100 + ((1 - t) * 100).round();
      beepDurationMs = 25; // Very short beeps for fast intervals
    }

    // Get cached beep with appropriate duration
    final cacheKey = '${(frequencyHz / 100).round() * 100}_$beepDurationMs';
    final beepData = _beepCache[cacheKey] ??
        _generateBeepWav(frequency: frequencyHz.toDouble(), durationMs: beepDurationMs);

    _beepTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) async {
      if (!_isBeeping || _beepPlayer == null) return;

      // Skip if still playing or too soon since last beep
      final now = DateTime.now();
      final timeSinceLastBeep = now.difference(_lastBeepTime).inMilliseconds;
      if (_isPlayingBeep || timeSinceLastBeep < (beepDurationMs + 20)) return;

      _isPlayingBeep = true;
      _lastBeepTime = now;
      try {
        await _beepPlayer!.stop();
        await _beepPlayer!.play(BytesSource(beepData));
      } catch (e) {
        debugPrint('Beep error: $e');
        _isPlayingBeep = false;
        // Recreate player on error
        _beepPlayer?.dispose();
        _beepPlayer = AudioPlayer();
        _beepPlayer!.setReleaseMode(ReleaseMode.stop);
        _beepPlayer!.onPlayerComplete.listen((_) {
          _isPlayingBeep = false;
        });
      }
    });

    // Play first beep immediately
    _playImmediateBeep(beepData);
  }

  Future<void> _playImmediateBeep(Uint8List beepData) async {
    if (_beepPlayer == null || _isPlayingBeep) return;

    _isPlayingBeep = true;
    _lastBeepTime = DateTime.now();
    try {
      await _beepPlayer!.stop();
      await _beepPlayer!.play(BytesSource(beepData));
    } catch (e) {
      debugPrint('Immediate beep error: $e');
      _isPlayingBeep = false;
    }
    // Note: _isPlayingBeep is reset by onPlayerComplete listener
  }

  /// Stop proximity beeping
  void stopProximityBeep() {
    _isBeeping = false;
    _beepTimer?.cancel();
    _beepTimer = null;
    _beepPlayer?.stop();
  }

  /// Check if beeping is active
  bool get isBeeping => _isBeeping;

  void dispose() {
    stopProximityBeep();
    _beepPlayer?.dispose();

    // Dispose all active sound players
    for (final playerList in _activePlayers.values) {
      for (final player in playerList) {
        player.dispose();
      }
    }
    _activePlayers.clear();
    _lastPlayTime.clear();
    _beepCache.clear();
  }
}

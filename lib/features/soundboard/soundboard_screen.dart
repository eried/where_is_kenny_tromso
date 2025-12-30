import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'sound_button.dart';

class SoundboardScreen extends StatefulWidget {
  const SoundboardScreen({super.key});

  @override
  State<SoundboardScreen> createState() => _SoundboardScreenState();
}

class _SoundboardScreenState extends State<SoundboardScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SoundItem> _sounds = [];
  bool _isLoading = true;
  String? _error;
  final Map<int, Uint8List> _placeholderSounds = {};

  @override
  void initState() {
    super.initState();
    _loadSounds();
    _generatePlaceholderSounds();
  }

  void _generatePlaceholderSounds() {
    // Generate unique placeholder sounds for each button
    final frequencies = [440, 523, 587, 659, 784, 880]; // Musical notes
    for (int i = 0; i < frequencies.length; i++) {
      _placeholderSounds[i] = _generateMuffledSound(frequencies[i].toDouble(), i);
    }
  }

  /// Generate a "muffled" Kenny-like sound
  Uint8List _generateMuffledSound(double baseFreq, int variation) {
    const sampleRate = 22050;
    const durationMs = 500;
    final numSamples = (sampleRate * durationMs / 1000).round();
    final samples = Int16List(numSamples);

    final random = math.Random(variation);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;

      // Create a "muffled" sound with multiple frequency components
      double sample = 0;

      // Base tone with vibrato
      final vibrato = 1 + 0.02 * math.sin(2 * math.pi * 5 * t);
      sample += math.sin(2 * math.pi * baseFreq * vibrato * t) * 0.5;

      // Add harmonics for richer sound
      sample += math.sin(2 * math.pi * baseFreq * 2 * t) * 0.2;
      sample += math.sin(2 * math.pi * baseFreq * 0.5 * t) * 0.3;

      // Add some "muffled" noise
      sample += (random.nextDouble() - 0.5) * 0.1;

      // Envelope: attack, sustain, release
      double envelope = 1.0;
      final attackEnd = numSamples * 0.05;
      final releaseStart = numSamples * 0.7;

      if (i < attackEnd) {
        envelope = i / attackEnd;
      } else if (i > releaseStart) {
        envelope = (numSamples - i) / (numSamples - releaseStart);
      }

      samples[i] = (sample * 32767 * 0.6 * envelope).round().clamp(-32768, 32767);
    }

    // Create WAV file
    final wavData = ByteData(44 + numSamples * 2);

    // RIFF header
    wavData.setUint8(0, 0x52);
    wavData.setUint8(1, 0x49);
    wavData.setUint8(2, 0x46);
    wavData.setUint8(3, 0x46);
    wavData.setUint32(4, 36 + numSamples * 2, Endian.little);
    wavData.setUint8(8, 0x57);
    wavData.setUint8(9, 0x41);
    wavData.setUint8(10, 0x56);
    wavData.setUint8(11, 0x45);

    // fmt chunk
    wavData.setUint8(12, 0x66);
    wavData.setUint8(13, 0x6D);
    wavData.setUint8(14, 0x74);
    wavData.setUint8(15, 0x20);
    wavData.setUint32(16, 16, Endian.little);
    wavData.setUint16(20, 1, Endian.little);
    wavData.setUint16(22, 1, Endian.little);
    wavData.setUint32(24, sampleRate, Endian.little);
    wavData.setUint32(28, sampleRate * 2, Endian.little);
    wavData.setUint16(32, 2, Endian.little);
    wavData.setUint16(34, 16, Endian.little);

    // data chunk
    wavData.setUint8(36, 0x64);
    wavData.setUint8(37, 0x61);
    wavData.setUint8(38, 0x74);
    wavData.setUint8(39, 0x61);
    wavData.setUint32(40, numSamples * 2, Endian.little);

    for (int i = 0; i < numSamples; i++) {
      wavData.setInt16(44 + i * 2, samples[i], Endian.little);
    }

    return wavData.buffer.asUint8List();
  }

  Future<void> _loadSounds() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/config/sounds.json');
      final data = json.decode(jsonString);
      final soundsList = (data['sounds'] as List)
          .map((s) => SoundItem.fromJson(s))
          .toList();

      // Shuffle the sounds for random order
      soundsList.shuffle(math.Random());

      setState(() {
        _sounds = soundsList;
        _isLoading = false;
      });
    } catch (e) {
      // If config doesn't exist, use default sounds
      final defaultSounds = _getDefaultSounds();
      defaultSounds.shuffle(math.Random());
      setState(() {
        _sounds = defaultSounds;
        _isLoading = false;
      });
    }
  }

  List<SoundItem> _getDefaultSounds() {
    return [
      SoundItem(
        id: 'killed_kenny',
        file: 'killed_kenny.mp3',
        label: 'They Killed Kenny!',
        icon: Icons.warning_amber,
      ),
      SoundItem(
        id: 'kenny_crying',
        file: 'kenny_crying.mp3',
        label: 'Kenny Crying',
        icon: Icons.sentiment_very_dissatisfied,
      ),
      SoundItem(
        id: 'kenny_muffled',
        file: 'kenny_muffled.mp3',
        label: 'Mmmph!',
        icon: Icons.record_voice_over,
      ),
      SoundItem(
        id: 'omg_kenny',
        file: 'omg_kenny.mp3',
        label: 'OMG Kenny!',
        icon: Icons.priority_high,
      ),
      SoundItem(
        id: 'kenny_dies',
        file: 'kenny_dies.mp3',
        label: 'Kenny Dies',
        icon: Icons.favorite_border,
      ),
      SoundItem(
        id: 'woah_kenny',
        file: 'woah_kenny.mp3',
        label: 'WOAH KENNY!',
        icon: Icons.mic,
      ),
    ];
  }

  Future<void> _playSound(SoundItem sound, int index) async {
    try {
      // Try to play the actual sound file first
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/${sound.file}'));
    } catch (e) {
      // Fall back to placeholder sound
      try {
        final placeholderIndex = index % _placeholderSounds.length;
        final placeholderData = _placeholderSounds[placeholderIndex];
        if (placeholderData != null) {
          await _audioPlayer.stop();
          await _audioPlayer.play(BytesSource(placeholderData));
        }
      } catch (e2) {
        debugPrint('Sound error: $e2');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _sounds.length,
      itemBuilder: (context, index) {
        final sound = _sounds[index];
        return SoundButton(
          label: sound.label,
          icon: sound.icon,
          color: _getColorForIndex(index),
          onPressed: () => _playSound(sound, index),
        );
      },
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }
}

class SoundItem {
  final String id;
  final String file;
  final String label;
  final IconData icon;

  SoundItem({
    required this.id,
    required this.file,
    required this.label,
    required this.icon,
  });

  factory SoundItem.fromJson(Map<String, dynamic> json) {
    return SoundItem(
      id: json['id'] as String,
      file: json['file'] as String,
      label: json['label'] as String,
      icon: _iconFromString(json['icon'] as String? ?? 'music_note'),
    );
  }

  static IconData _iconFromString(String name) {
    switch (name) {
      case 'skull':
        return Icons.dangerous;
      case 'warning':
        return Icons.priority_high;
      case 'rage':
        return Icons.sentiment_very_dissatisfied;
      case 'block':
        return Icons.volume_off;
      case 'crying':
        return Icons.water_drop;
      case 'heart':
        return Icons.heart_broken;
      case 'celebration':
        return Icons.celebration;
      case 'question':
        return Icons.help_outline;
      case 'voice':
        return Icons.record_voice_over;
      case 'group':
        return Icons.groups;
      case 'music':
        return Icons.music_note;
      case 'spanish':
        return Icons.flag;
      case 'language':
        return Icons.translate;
      case 'play':
        return Icons.play_circle;
      case 'church':
        return Icons.church;
      case 'mic':
        return Icons.mic;
      default:
        return Icons.music_note;
    }
  }
}

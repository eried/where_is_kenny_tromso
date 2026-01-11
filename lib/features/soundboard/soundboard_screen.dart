import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sound_button.dart';
import '../../services/audio_service.dart';

class SoundboardScreen extends StatefulWidget {
  const SoundboardScreen({super.key});

  @override
  State<SoundboardScreen> createState() => _SoundboardScreenState();
}

class _SoundboardScreenState extends State<SoundboardScreen> {
  final AudioService _audioService = AudioService();
  List<SoundItem> _sounds = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSounds();
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
      soundsList.shuffle();

      setState(() {
        _sounds = soundsList;
        _isLoading = false;
      });
    } catch (e) {
      // If config doesn't exist, use default sounds
      final defaultSounds = _getDefaultSounds();
      defaultSounds.shuffle();
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
    // Use AudioService which supports multiple simultaneous sounds
    await _audioService.playSound(sound.id, 'sounds/${sound.file}');
  }

  @override
  void dispose() {
    _audioService.dispose();
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
    final orangeTones = [
      const Color(0xFFFF6B35), // Bright orange
      const Color(0xFFF77F00), // Orange
      const Color(0xFFFF8C42), // Light orange
      const Color(0xFFFF9E5C), // Peach orange
      const Color(0xFFFFB347), // Pastel orange
      const Color(0xFFFF8243), // Mango orange
      const Color(0xFFFF7D47), // Coral orange
      const Color(0xFFFFA500), // Classic orange
      const Color(0xFFFF9052), // Soft orange
      const Color(0xFFFF8533), // Deep orange
    ];
    return orangeTones[index % orangeTones.length];
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

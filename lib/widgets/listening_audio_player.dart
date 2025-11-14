import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../core/supabase_client.dart';

class ListeningAudioPlayer extends StatefulWidget {
  final String audioPath; // relative path or full URL
  final String bucket;
  const ListeningAudioPlayer({super.key, required this.audioPath, this.bucket = 'listening-audio'});

  @override
  State<ListeningAudioPlayer> createState() => _ListeningAudioPlayerState();
}

class _ListeningAudioPlayerState extends State<ListeningAudioPlayer> {
  late final AudioPlayer _player;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    String url = widget.audioPath;
    if (!url.startsWith('http')) {
      url = Supa.client.storage.from(widget.bucket).getPublicUrl(widget.audioPath);
    }
    try {
      await _player.setUrl(url);
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return IconButton(
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                onPressed: () => playing ? _player.pause() : _player.play(),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                final pos = snapshot.data ?? Duration.zero;
                final dur = _player.duration ?? Duration.zero;
                final v = dur.inMilliseconds == 0 ? 0.0 : pos.inMilliseconds / dur.inMilliseconds;
                return Slider(
                  value: v.clamp(0.0, 1.0),
                  onChanged: (nv) {
                    if (_player.duration != null) {
                      _player.seek(_player.duration! * nv);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


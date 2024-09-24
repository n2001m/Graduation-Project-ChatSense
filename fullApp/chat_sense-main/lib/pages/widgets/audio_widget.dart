import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum AudioSourceType { local, asset, network }

class SimpleAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final AudioSourceType audioSourceType;

  const SimpleAudioPlayer(
      {super.key, required this.audioUrl, required this.audioSourceType});

  @override
  SimpleAudioPlayerState createState() => SimpleAudioPlayerState();
}

class SimpleAudioPlayerState extends State<SimpleAudioPlayer> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setAudio();
  }

  Future<void> _setAudio() async {
    try {
      if (widget.audioSourceType == AudioSourceType.local) {
        // _duration = await _audioPlayer.setFilePath(widget.audioUrl) ?? Duration.zero;
        _duration = await _audioPlayer
                .setAudioSource(AudioSource.file(widget.audioUrl)) ??
            Duration.zero;
        return;
      }
      if (widget.audioSourceType == AudioSourceType.asset) {
        _duration =
            await _audioPlayer.setAsset(widget.audioUrl) ?? Duration.zero;
        return;
      }
      if (widget.audioSourceType == AudioSourceType.network) {
        _duration = await _audioPlayer.setUrl(widget.audioUrl) ?? Duration.zero;
        return;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  void _updatePosition(Duration position) {
    setState(() {
      _position = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: min(_position.inMilliseconds.toDouble(),
              _duration.inMilliseconds.toDouble()),
          max: _duration.inMilliseconds.toDouble(),
          onChanged: (double value) {
            _audioPlayer.seek(Duration(milliseconds: value.toInt()));
            _updatePosition(Duration(milliseconds: value.toInt()));
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: () {
                _audioPlayer.seek(
                    Duration(milliseconds: _position.inMilliseconds - 10000));
              },
            ),
            IconButton(
              icon: Icon(_audioPlayer.playing ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (_audioPlayer.playing) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.play();
                  _audioPlayer.positionStream.listen(_updatePosition);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.forward_10),
              onPressed: () {
                _audioPlayer.seek(
                    Duration(milliseconds: _position.inMilliseconds + 10000));
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

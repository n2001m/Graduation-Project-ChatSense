import 'dart:developer';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'preview_dialog.dart';

class AudioRecorderButton extends StatefulWidget {
  const AudioRecorderButton(
      {super.key, required this.recieverEmail, required this.recieverID});
  final String recieverEmail;
  final String recieverID;

  @override
  State<AudioRecorderButton> createState() => _AudioRecorderButtonState();
}

class _AudioRecorderButtonState extends State<AudioRecorderButton> {
  late FlutterSoundRecorder _recorder;
  Codec _codec = Codec.aacMP4;

  showPreviewDialog(String v) {
    showDialog(
        context: context,
        useSafeArea: true,
        builder: (c) {
          return PreviewDialogWidget(
            audioPath: v,
            recieverEmail: widget.recieverEmail,
            recieverID: widget.recieverID,
            previewType: PreviewType.edit,
          );
        });
  }

  Future<void> setCodec(Codec codec) async {
    // bool _encoderSupported = await _recorder.isEncoderSupported(codec);
    // bool _decoderSupported = await _recorder.isEncoderSupported(codec);

    setState(() {
      _codec = codec;
    });
  }

  Future<void> startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // throw 'Microphone permission not granted';
    }
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      ),
    );

    var tempDir = await getTemporaryDirectory();
    String path =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}flutter_sound${ext[_codec.index]}';
    await _recorder.openRecorder();
    await _recorder.startRecorder(toFile: path);
    setState(() {});
  }

  Future<void> stopRecording() async {
    final path = await _recorder.stopRecorder();
    final file = File(path!);
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    var tempDir = await getTemporaryDirectory();
    final newItem = await file.copy(
        "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}flutter_sound${ext[_codec.index]}");
    log("path....   $path");
    log("newItem....   ${newItem.path}");
    if (mounted) {
      showPreviewDialog(newItem.path);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    setCodec(_codec);
  }

  @override
  void dispose() {
    super.dispose();
    _recorder.stopRecorder();
    _recorder.closeRecorder();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _recorder.isRecording ? Colors.red : Colors.green),
      margin: const EdgeInsets.only(right: 10),
      child: IconButton(
          onPressed: () {
            if (_recorder.isRecording) {
              stopRecording();
            } else {
              startRecording();
            }
          },
          style: IconButton.styleFrom(
              backgroundColor:
                  _recorder.isRecording ? Colors.red : Colors.green),
          icon: Icon(
            _recorder.isRecording ? Icons.stop : Icons.mic,
            color: Colors.white,
          )),
    );
  }
}

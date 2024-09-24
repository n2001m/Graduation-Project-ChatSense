import 'package:flutter/material.dart';
import 'audio_widget.dart';
import 'send_audio_message_button.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum PreviewType { edit, viewOnly }

class PreviewDialogWidget extends StatefulWidget {
  const PreviewDialogWidget({
    super.key,
    required this.audioPath,
    required this.recieverEmail,
    required this.recieverID,
    required this.previewType,
  });

  final String audioPath;
  final String recieverEmail;
  final String recieverID;
  final PreviewType previewType;

  @override
  State<PreviewDialogWidget> createState() => _PreviewDialogWidgetState();
}

Future<List<String>> predictEmotion(String audioFilePath) async {
  final convertedFilePath = await convertToWav(audioFilePath);
  // final convertedFilePath = audioFilePath;
  final url = Uri.parse('https://7508-178-80-32-44.ngrok-free.app/predict');
  var request = http.MultipartRequest('POST', url);

  // Attach the WAV file to the POST request
  request.files
      .add(await http.MultipartFile.fromPath('audio_file', convertedFilePath));

  try {
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<String> predictedEmotions =
          List<String>.from(data['predicted_labels']);
      return predictedEmotions;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    throw Exception('Failed to send data: $e');
  }
}

Future<String> convertToWav(String originalFilePath) async {
  String outputPath = originalFilePath.replaceAll(RegExp(r'\.(\w+)$'), '.wav');
  String command = '-i "$originalFilePath" -ar 16000 -ac 1 "$outputPath"';

  await FFmpegKit.execute(command).then((session) async {
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      // SUCCESS
      print('Conversion successful');
    } else if (ReturnCode.isCancel(returnCode)) {
      // CANCEL
      throw Exception('Conversion canceled');
    } else {
      // ERROR
      throw Exception('Failed to convert file to WAV format');
    }
  });

  return outputPath;
}

class _PreviewDialogWidgetState extends State<PreviewDialogWidget> {
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  Future<List<String>>? _predictionFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String emotion = "";

  setSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  @override
  void initState() {
    super.initState();
    setSession();
    if (widget.previewType == PreviewType.edit) {
      _predictionFuture = predictEmotion(widget.audioPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Voice Message',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            SimpleAudioPlayer(
              audioSourceType: widget.previewType == PreviewType.edit
                  ? AudioSourceType.local
                  : AudioSourceType.network,
              audioUrl: widget.audioPath,
            ),
            if (_predictionFuture != null)
              FutureBuilder<List<String>>(
                future: _predictionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          emotion =
                              "The voice has following emotions: ${snapshot.data!.join(', ')}";
                        });
                      }
                    });
                    return Text(emotion);
                  }
                  return Container();
                },
              ),
            if (widget.previewType == PreviewType.edit)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: SendAudioButton(
                      recieverEmail: widget.recieverEmail,
                      recieverID: widget.recieverID,
                      audioFile: widget.audioPath,
                      emotions: emotion,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

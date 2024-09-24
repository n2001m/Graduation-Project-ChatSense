import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../services/chat/chat_service.dart';

class SendAudioButton extends StatefulWidget {
  const SendAudioButton(
      {super.key,
      required this.recieverEmail,
      required this.recieverID,
      required this.audioFile,
      required this.emotions});
  final String recieverEmail;
  final String recieverID;
  final String audioFile;
  final String emotions;

  @override
  State<SendAudioButton> createState() => _SendAudioButtonState();
}

class _SendAudioButtonState extends State<SendAudioButton> {
  double? _uploadProgress;
  String _downloadUrl = '';
  final ChatService _chatService = ChatService();

  bool fileUploading = false;

  Future<void> _uploadFile() async {
    final file = File(widget.audioFile);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong try again")));
      Navigator.pop(context);
      return;
    }
    try {
      if (fileUploading) return;
      fileUploading = true;
      setState(() {});
      final fileName = file.path.split('/').last;
      final storageRef =
          FirebaseStorage.instance.ref().child('files/$fileName');
      final uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          _uploadProgress = event.bytesTransferred / event.totalBytes;
        });
      }).onError((error) {
        print('Upload Error: $error');
      });

      await uploadTask.whenComplete(() {
        print('File Uploaded');
        storageRef.getDownloadURL().then((downloadUrl) async {
          _downloadUrl = downloadUrl;
          await _chatService.sendMessage(
              widget.emotions, widget.recieverID, "Voice Message",
              voiceMessageUrl: _downloadUrl);
          if (mounted) {
            Navigator.pop(context);
          }
          fileUploading = false;
        });
      });
      fileUploading = false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Exception: $e")));
      }
      fileUploading = false;
      setState(() {});
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _uploadFile,
      child: fileUploading
          ? Row(
              children: [
                const Text("Uploading "),
                CircularProgressIndicator(
                  value: _uploadProgress == null
                      ? null
                      : _uploadProgress! < 0
                          ? 0
                          : _uploadProgress! > 1
                              ? 1
                              : _uploadProgress,
                ),
              ],
            )
          : const Text('Send'),
    );
  }
}

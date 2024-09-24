import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String? voiceUrl;
  final String? emotion;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.voiceUrl,
    this.emotion,
  });

  //convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'recieverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'voiceUrl': voiceUrl,
      'emotionMsg': emotion
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderUsername;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderUsername,
    required this.receiverID,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderUsername': senderUsername,
      'recieverID': receiverID,
      'message': message,
      'timestamp' : timestamp,
    };
  }
}

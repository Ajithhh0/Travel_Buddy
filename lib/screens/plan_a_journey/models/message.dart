import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderUserEmail;
  final String receiverID;
  final String message;
  final String username;
  final String userImage;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderUserEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    required this.username,
    required this.userImage
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderUserEmail': senderUserEmail,
      'recieverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'username' : username ,
      "userImage": userImage, };
  }
}

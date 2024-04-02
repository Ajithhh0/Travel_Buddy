import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/message.dart';

class ChatService {
  //get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        //go through individual user
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Future<void> sendMessages(String receiverID, message) async {
    //current user info
    final String currentUID = _auth.currentUser!.uid;
    final String currentUserName = _auth.currentUser!.displayName!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderID: currentUID,
      senderUsername: currentUserName,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    //construct chat room ID
    List<String> ids = [currentUID, receiverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    //add new msgs to db
    await _firestore
        .collection('chat rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //get messages
  Stream<QuerySnapshot> getMesssages(String userID, otherUserID) {
    //chatroom for 2 users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}

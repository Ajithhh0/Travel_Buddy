import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy/screens/chat/chat_page.dart';
import 'package:travel_buddy/screens/chat/chat_services.dart';
import 'package:travel_buddy/screens/chat/user_tile.dart';

class ChatScreen extends StatelessWidget {
  final ChatService _chatServices = ChatService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatServices.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ListView.builder(
          itemCount: snapshot.data?.length,
          itemBuilder: (context, index) {
            var userData = snapshot.data?[index];
            return _buildUserListItem(userData!, context);
          },
        );
      },
    );
  }

 Stream<String> _getRecentMessage(String receiverID) {
  final currentUserID = auth.currentUser!.uid;
  List<String> ids = [currentUserID, receiverID];
  ids.sort();
  String chatRoomId = ids.join('_');

  return _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      Map<String, dynamic> messageData =
          snapshot.docs.first.data() as Map<String, dynamic>;
      return messageData['message'];
    } else {
      return 'No messages yet';
    }
  });
}

 Widget _buildUserListItem(
    Map<String, dynamic> userData, BuildContext context) {
  if (userData['email'] != auth.currentUser!.email) {
    return StreamBuilder<String>(
      stream: _getRecentMessage(userData['uid']),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return UserTile(
            avatarUrl: userData['avatar_url'],
            username: userData['username'],
            recentMessage: snapshot.data!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    userName: userData['username'],
                    avatarUrl: userData['avatar_url'],
                    receiverID: userData['uid'],
                    receiverEmail: userData['email'],
                  ),
                ),
              );
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  } else {
    return Container();
  }
}
}

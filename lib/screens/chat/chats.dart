import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy/screens/chat/chat_page.dart';
import 'package:travel_buddy/screens/chat/chat_services.dart';
import 'package:travel_buddy/screens/chat/user_tile.dart';

class ChatScreen extends StatelessWidget {
  final ChatService _chatServices = ChatService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: _chatServices.getUsersStream(),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              var userData = snapshot.data?[index];
              return _buildUserListItem(userData!, context);
            },
          );
        }));
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    
    if(userData['email'] != auth.currentUser!.email ){
      return UserTile(
      avatarUrl: userData['avatar_url'],
      username: userData['username'],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              userName: userData['username'], avatarUrl: userData['avatar_url'], receiverID: userData['uid'], receiverEmail: userData['email'],
            ),
          ),
        );
      },
    );
    } else {
      return  Container();
    }
  }
}

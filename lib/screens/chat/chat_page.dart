import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy/screens/chat/chat_services.dart';

class ChatPage extends StatelessWidget {
  final String userName;
  final String receiverID;
  final String avatarUrl;

  ChatPage(
      {Key? key,
      required this.userName,
      required this.avatarUrl,
      required this.receiverID})
      : super(key: key);

  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessages(receiverID, _messageController.text);

      //clear controller
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 195, // Adjust the width of the leading widget
        leading: Row(
          // Use Row to align the avatar and back button
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(
              width: 14.0,
            ),
            CircleAvatar(
              radius: 20, // Adjust the size of the avatar
              backgroundImage: NetworkImage(avatarUrl),
            ),
          ],
        ),
        title: Text(userName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ), // Replace Container() with your chat UI
    );
  }

  Widget _buildMessageList() {
    String senderID = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
        stream: _chatService.getMesssages(receiverID, senderID),
        builder: (context, snapshot) {
          if (!snapshot.hasError) {
            return const Text('Error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Text(data['messages']);
  }

  Widget _buildUserInput() {
    return Row(children: [
      Expanded(
        child: TextField(
          autocorrect: true,
          controller: _messageController,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Type your message here...'),
        ),
      ),
      IconButton(onPressed: sendMessage, icon: Icon(Icons.send),)
    ]);
  }
}

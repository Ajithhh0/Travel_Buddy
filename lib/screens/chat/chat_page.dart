import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy/screens/chat/chat_bubble.dart';
import 'package:travel_buddy/screens/chat/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String receiverID;
  final String avatarUrl;
  final String receiverEmail;

  ChatPage(
      {Key? key,
      required this.userName,
      required this.avatarUrl,
      required this.receiverID,
      required this.receiverEmail})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(microseconds: 500), () => scrollDown());
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    print('ook');
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
    print('done');
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessages(
          widget.receiverID, _messageController.text);

      //clear controller
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 195,
        leading: Row(
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
              radius: 20,
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
          ],
        ),
        title: Text(widget.userName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
        stream: _chatService.getMesssages(widget.receiverID, senderID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            controller: _scrollController,
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == _auth.currentUser!.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              message: data['message'],
              isCurrentUser: isCurrentUser,
            ),
          ],
        ));
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0, left: 5.0),
      child: Row(children: [
        Expanded(
          child: TextField(
            autofocus: false,
            autocorrect: true,
            controller: _messageController,
            decoration: InputDecoration(
                hoverColor: Colors.grey[400],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                fillColor: Colors.grey,
                labelText: 'Type your message here...'),
            focusNode: myFocusNode,
          ),
        ),
        const SizedBox(
          width: 8.0,
        ),
        Container(
          decoration:
              const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          margin: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        )
      ]),
    );
  }
}

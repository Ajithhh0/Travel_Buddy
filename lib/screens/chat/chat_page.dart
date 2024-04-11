import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/screens/chat/chat_bubble.dart';
import 'package:travel_buddy/screens/chat/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String receiverID;
  final String avatarUrl;
  final String receiverEmail;

  ChatPage({
    Key? key,
    required this.userName,
    required this.avatarUrl,
    required this.receiverID,
    required this.receiverEmail,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessages(
        widget.receiverID,
        _messageController.text,
      );

      // Clear the controller
      _messageController.clear();
    }
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
           GestureDetector(
              onTap: () {
                // navigate to buddy profile page
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.avatarUrl),
                  ),
                  const SizedBox(width: 18.0),
                  Text(widget.userName,style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
                  
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.call))
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          const SizedBox(height: 8.0),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: _chatService.getMesssages(
        widget.receiverID,
        authenticatedUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final loadedMessages = snapshot.data!.docs;
        if (loadedMessages.isEmpty) {
          return Center(
            child: Text(
              'No messages',
              style: TextStyle(color: Colors.grey[700]),
            ),
          );
        }

        return ListView.builder(
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final currentMessage =
                loadedMessages[index].data() as Map<String, dynamic>;
            final currentMessageTimestamp =
                currentMessage['timestamp'] as Timestamp;

            // Group messages by day
            final currentMessageDay =
                DateTime.fromMillisecondsSinceEpoch(currentMessageTimestamp.millisecondsSinceEpoch)
                    .day;

            // Check if the previous message is from a different day
            final previousMessageDay = index + 1 < loadedMessages.length
                ? DateTime.fromMillisecondsSinceEpoch(
                        (loadedMessages[index + 1].data()
                            as Map<String, dynamic>)['timestamp']
                            .millisecondsSinceEpoch)
                    .day
                : null;

            final isNewDay = previousMessageDay == null || previousMessageDay != currentMessageDay;

            if (isNewDay) {
              return Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    child: Text(
                      DateFormat('EEE, MMM d, yyyy').format(currentMessageTimestamp.toDate()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  _buildMessageBubble(currentMessage, authenticatedUser.uid, index, loadedMessages),
                ],
              );
            } else {
              return _buildMessageBubble(currentMessage, authenticatedUser.uid, index, loadedMessages);
            }
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> currentMessage,
    String currentUserId,
    int index,
    List<QueryDocumentSnapshot<Object?>> loadedMessages,
  ) {
    final currentMessageTimestamp = currentMessage['timestamp'] as Timestamp;
    final currentMessageDay =
        DateTime.fromMillisecondsSinceEpoch(currentMessageTimestamp.millisecondsSinceEpoch).day;

    final nextMessageDay = index + 1 < loadedMessages.length
        ? DateTime.fromMillisecondsSinceEpoch(
                (loadedMessages[index + 1].data() as Map<String, dynamic>)['timestamp']
                    .millisecondsSinceEpoch)
            .day
        : null;

    final isNewDay = nextMessageDay == null || nextMessageDay != currentMessageDay;

    final currentMessageUserId = currentMessage['senderID'];
    final nextMessage = index + 1 < loadedMessages.length
        ? loadedMessages[index + 1].data() as Map<String, dynamic>
        : null;

    final nextMessageUserId = nextMessage != null ? nextMessage['senderID'] : null;
    final nextUserIsSame = nextMessageUserId == currentMessageUserId;

    if (isNewDay && nextUserIsSame) {
      return MessageBubble.first(
        userImage: currentMessage['userImage'],
        username: currentMessage['username'],
        message: currentMessage['message'],
        timestamp: currentMessage['timestamp'],
        isMe: currentUserId == currentMessageUserId,
      );
    } else if (nextUserIsSame) {
      return MessageBubble.next(
        message: currentMessage['message'],
        timestamp: currentMessage['timestamp'],
        isMe: currentUserId == currentMessageUserId,
      );
    } else {
      return MessageBubble.first(
        userImage: currentMessage['userImage'],
        username: currentMessage['username'],
        message: currentMessage['message'],
        timestamp: currentMessage['timestamp'],
        isMe: currentUserId == currentMessageUserId,
      );
    }
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0, left: 15.0),
      child: Row(children: [
        Expanded(
          child: TextField(
            autofocus: false,
            autocorrect: true,
            controller: _messageController,
            decoration: InputDecoration(
              hoverColor: Colors.grey[400],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28.0),
              ),
              fillColor: Colors.grey,
              labelText: 'Type your message here...',
            ),
          ),
        ),
        const SizedBox(
          width: 8.0,
        ),
        IconButton(
          onPressed: (){},
          icon: const Icon(Icons.add)),
        const SizedBox(width: 8.0,),
        Container(
          decoration:
              const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          margin: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send_outlined,
              color: Colors.white,
            ),
          ),
        )
      ]),
    );
  }
}
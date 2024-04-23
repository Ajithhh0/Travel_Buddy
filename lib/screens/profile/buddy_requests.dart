import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuddyRequests extends StatefulWidget {
  const BuddyRequests({Key? key}) : super(key: key);

  @override
  State<BuddyRequests> createState() => _BuddyRequestsState();
}

class _BuddyRequestsState extends State<BuddyRequests> {
  late final String currentUserUid;

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buddy Requests'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No requests'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null || !userData.containsKey('buddy_requests')) {
            return Center(child: Text('No requests'));
          }

          final buddyRequests = userData['buddy_requests'] as List<dynamic>;

          if (buddyRequests.isEmpty) {
            return Center(child: Text('No requests'));
          }

          final pendingRequests = buddyRequests.where((request) {
            return request['acceptance_status'] == 1;
          }).toList();

          if (pendingRequests.isEmpty) {
            return Center(child: Text('No pending requests'));
          }

          return ListView.builder(
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              final senderId = request['senderId'];

              return Card(
                child: ListTile(
                  leading: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(senderId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return SizedBox();
                      }

                      final senderData = snapshot.data!.data() as Map<String, dynamic>;
                      final avatarUrl = senderData['avatar_url'] as String?;
                      final senderUsername = senderData['username'] as String?;

                      return CircleAvatar(
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null ? Icon(Icons.person) : null,
                      );
                    },
                  ),
                  title: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return SizedBox();
                      }

                      final senderData = snapshot.data!.data() as Map<String, dynamic>;
                      final senderUsername = senderData['username'] as String?;

                      return Text(senderUsername ?? 'Unknown');
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _acceptBuddyRequest(senderId, currentUserUid);
                        },
                        icon: Icon(Icons.check),
                      ),
                      IconButton(
                        onPressed: () {
                           _rejectBuddyRequest(senderId, currentUserUid);
                        },
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Future<void> _acceptBuddyRequest(String senderId, String currentUserUid) async {
  final senderRef = FirebaseFirestore.instance.collection('users').doc(senderId);
  final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserUid);

  final currentUserDoc = await currentUserRef.get();
  final currentUserData = currentUserDoc.data() as Map<String, dynamic>?;

  if (currentUserData != null && currentUserData.containsKey('buddy_requests')) {
    final buddyRequests = currentUserData['buddy_requests'] as List<dynamic>;

   
    final requestIndex = buddyRequests.indexWhere((request) {
      return request['senderId'] == senderId && request['acceptance_status'] == 1;
    });

    if (requestIndex != -1) {
      
      buddyRequests[requestIndex]['acceptance_status'] = 2;

      
      await currentUserRef.update({
        'buddy_requests': buddyRequests,
        'buddies': FieldValue.arrayUnion([senderRef])
      });

      // Update the sender's "buddies" field
      await senderRef.update({
        'buddies': FieldValue.arrayUnion([currentUserRef])
      });
    }
  }
}

Future<void> _rejectBuddyRequest(String senderId, String currentUserUid) async {
  final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserUid);

  final currentUserDoc = await currentUserRef.get();
  final currentUserData = currentUserDoc.data() as Map<String, dynamic>?;

  if (currentUserData != null && currentUserData.containsKey('buddy_requests')) {
    final buddyRequests = currentUserData['buddy_requests'] as List<dynamic>;

    final requestIndex = buddyRequests.indexWhere((request) {
      return request['senderId'] == senderId && request['acceptance_status'] == 1;
    });

    if (requestIndex != -1) {
      
      buddyRequests[requestIndex]['acceptance_status'] = 0;

      
      await currentUserRef.update({
        'buddy_requests': buddyRequests,
      });
    }
  }
}
}

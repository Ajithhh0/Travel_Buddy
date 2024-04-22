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
                          // Handle accept action
                        },
                        icon: Icon(Icons.check),
                      ),
                      IconButton(
                        onPressed: () {
                          // Handle decline action
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
}

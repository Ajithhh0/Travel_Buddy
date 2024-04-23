import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? username;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 330,
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    username = val;
                  });
                },
                decoration: InputDecoration(
                  fillColor: Colors.grey,
                  hintText: 'Search',
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              username = null;
                            });
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (username != null && username!.length >= 1)
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('username', isGreaterThanOrEqualTo: username)
                    .where('username', isLessThan: username! + 'z')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final List<DocumentSnapshot> users =
                      snapshot.data!.docs.cast<DocumentSnapshot>();

                  if (users.isEmpty) {
                    return const Center(
                      child: Text('No User Found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final buddyId = user.id;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            user['avatar_url'] ?? '',
                          ),
                        ),
                        title: Text(
                          user['username'] ?? '',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            if (await _isBuddy(buddyId)) {
                              await _removeRequest(buddyId);
                            } else {
                              await _addBuddy(user);
                            }
                            setState(() {});
                          },
                          child: FutureBuilder<bool>(
                            future: _isBuddy(buddyId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Loading...');
                              }

                              return Text(snapshot.data! ? "Remove" : "Send Request");
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<bool> _isBuddy(String buddyId) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final buddyDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(buddyId)
        .get();

    if (buddyDoc.exists) {
      final buddyData = buddyDoc.data() as Map<String, dynamic>;
      if (buddyData.containsKey('buddy_requests')) {
        final buddyRequests = buddyData['buddy_requests'] as List<dynamic>;
        return buddyRequests.any((request) =>
            request['senderId'] == currentUserUid &&
            request['acceptance_status'] == 1);
      }
    }

    return false;
  }

  Future<void> _addBuddy(DocumentSnapshot user) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final buddyId = user.id;

    if (await _isBuddy(buddyId)) {
      // Remove the existing request
      await _removeRequest(buddyId);
    } else {
      // Create a new request
      Map<String, dynamic> requestDetails = {
        'senderId': currentUserUid,
        'acceptance_status': 1, // Assuming 1 means accepted, modify if necessary
      };

      // Get the reference to the buddy's document
      DocumentReference buddyRef =
          FirebaseFirestore.instance.collection('users').doc(buddyId);

      // Update the buddy's document with buddy_requests field
      await buddyRef.set({
        'buddy_requests': FieldValue.arrayUnion([requestDetails])
      }, SetOptions(merge: true));
    }
  }

  Future<void> _removeRequest(String buddyId) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final buddyRef = FirebaseFirestore.instance.collection('users').doc(buddyId);

    final buddyDoc = await buddyRef.get();
    if (buddyDoc.exists) {
      final buddyData = buddyDoc.data() as Map<String, dynamic>;
      if (buddyData.containsKey('buddy_requests')) {
        final buddyRequests = buddyData['buddy_requests'] as List<dynamic>;
        final updatedBuddyRequests = buddyRequests
            .where((request) => request['senderId'] != currentUserUid)
            .toList();

        await buddyRef.update({
          'buddy_requests': updatedBuddyRequests,
        });
      }
    }
  }
}
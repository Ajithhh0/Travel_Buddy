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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search your Buddies'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                labelText: "Search",
              ),
              onChanged: (val) {
                setState(() {
                  username = val;
                });
              },
            ),
          ),
          if (username != null && username!.length > 1)
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('username', isEqualTo: username)
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
                              await _removeBuddy(buddyId);
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

                              return Text(snapshot.data! ? "Remove" : "Add");
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
        .doc(currentUserUid)
        .collection('buddies')
        .doc(buddyId)
        .get();
    return buddyDoc.exists;
  }

  Future<void> _addBuddy(DocumentSnapshot user) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final buddyData = user.data() as Map<String, dynamic>;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection("buddies")
        .doc(user.id)
        .set(buddyData);
  }

  Future<void> _removeBuddy(String buddyId) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection("buddies")
        .doc(buddyId)
        .delete();
  }
}

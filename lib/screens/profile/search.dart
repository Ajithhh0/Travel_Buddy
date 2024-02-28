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

                      return FutureBuilder<DocumentSnapshot>(
                        future: user.reference
                            .collection('buddies')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(
                              title: Text('Loading...'),
                              trailing: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return ListTile(
                              title: Text('Error: ${snapshot.error}'),
                            );
                          }

                          final bool isBuddy = snapshot.data!.exists;

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
  if (isBuddy) {
    // Remove buddy
    await user.reference
        .collection("buddies")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
  } else {
    // Add buddy
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final currentUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .get()
        .then((snapshot) => snapshot.data());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(buddyId) // Buddy's UID
        .collection("buddies")
        .doc(currentUserUid) // Current user's UID
        .set(currentUserData ?? {});
  }
  setState(() {});
},

                              child: Text(
                                isBuddy ? "Remove" : "Add",
                              ),
                            ),
                          );
                        },
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
}

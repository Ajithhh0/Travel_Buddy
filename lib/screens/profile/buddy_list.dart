import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuddyList extends StatefulWidget {
  const BuddyList({Key? key}) : super(key: key);

  @override
  _BuddyListState createState() => _BuddyListState();
}

class _BuddyListState extends State<BuddyList> {
  late Stream<QuerySnapshot> _buddiesStream;

  @override
  void initState() {
    super.initState();
    _buddiesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('buddies')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddy List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _buddiesStream,
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

          final buddies = snapshot.data!.docs;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Total Buddies: ${buddies.length}'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: buddies.length,
                  itemBuilder: (context, index) {
                    final buddy = buddies[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(buddy['avatar_url'] ?? ''),
                      ),
                      title: Text(buddy['username'] ?? ''),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

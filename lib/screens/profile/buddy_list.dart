import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy/screens/profile/buddy_profile.dart';

class BuddyList extends StatefulWidget {
  const BuddyList({Key? key}) : super(key: key);

  @override
  _BuddyListState createState() => _BuddyListState();
}

class _BuddyListState extends State<BuddyList> {
  late final Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddy List'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
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

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null || !userData.containsKey('buddies')) {
            return const Center(
              child: Text('No buddies found'),
            );
          }

          final buddies = (userData['buddies'] as List<dynamic>)
    .map((buddyRef) => buddyRef as DocumentReference)
    .toList();
     
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
                    final buddyRef = buddies[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: buddyRef.get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('Loading...'),
                          );
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const ListTile(
                            title: Text('N/A'),
                          );
                        }

                        final buddyData = snapshot.data!.data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            // Navigate to buddy's profile page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BuddyProfilePage(buddy: buddyData),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(buddyData['avatar_url'] ?? ''),
                            ),
                            title: Text(buddyData['username'] ?? ''),
                          ),
                        );
                      },
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
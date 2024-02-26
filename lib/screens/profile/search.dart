import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

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
                  labelText: "Search"),
              onChanged: (val) {
                username = val;
                setState(() {});
              },
            ),
          ),
          if (username != null)
            if (username!.length > 1)
              FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('username', isEqualTo: username)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // if(snapshot.data == null){

                    // }
                    if (snapshot.data?.docs.isEmpty ?? false) {
                      return const Text("No User Found");
                    }
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data?.docs.length ?? 0,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = snapshot.data!.docs[index];
                          return ListTile(
                            title: Text(
                              doc['username'],
                            ),
                            trailing: FutureBuilder<DocumentSnapshot>(
                                future: doc.reference
                                    .collection('buddies')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data?.exists ?? false) {
                                      return ElevatedButton(
                                        onPressed: () async {
                                          await doc.reference
                                            .collection("buddies")
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .delete();
                                            setState(() {
                                              
                                            });
                                        },
                                        child: const Text(
                                          "Remove",
                                        ),
                                      );
                                    }
                                    return ElevatedButton(
                                      onPressed: () async {
                                       await doc.reference
                                            .collection("buddies")
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .set({
                                              'time' : DateTime.now(),
                                            });
                                            setState(() {
                                              
                                            });
                                      },
                                      child: const Text(
                                        "Add",
                                      ),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                          );
                        },
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
        ],
      ),
    );
  }
}

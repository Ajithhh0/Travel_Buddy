import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripRequestsScreen extends StatefulWidget {
  @override
  _TripRequestsScreenState createState() => _TripRequestsScreenState();
}

class _TripRequestsScreenState extends State<TripRequestsScreen> {
  late StreamController<bool> _controller;

  @override
  void initState() {
    super.initState();
    _controller = StreamController<bool>();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) {
      // Handle the case where the current user is not authenticated
      return Scaffold(
        body: Center(
          child: Text('User not authenticated'),
        ),
      );
    }
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> requestsData = userData['requests'] ?? [];

          // Filter requests with req_status 1 (pending)
          final List<dynamic> pendingRequests = requestsData
              .where((request) => request['req_status'] == 1)
              .toList();

          if (pendingRequests.isEmpty) {
            _controller.add(false);
            return const Center(
              child: Text('No trip requests'),
            );
          }

          return ListView.builder(
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              final tripId = request['trip'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('trips')
                    .doc(tripId)
                    .get(),
                builder: (context, tripSnapshot) {
                  if (tripSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (tripSnapshot.hasError) {
                    return Center(child: Text('Error: ${tripSnapshot.error}'));
                  }

                  final tripData =
                      tripSnapshot.data!.data() as Map<String, dynamic>;
                  final tripName = tripData['trip_name'];
                  final formattedDate = tripData['created_at'];
                  final startLocation = tripData['starting_from'];
                  final destination = tripData['destination'];

                  return Card(
                    child: ListTile(
                      title: Text(tripName ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${formattedDate ?? ''}'),
                          Text('From: ${startLocation ?? ''}'),
                          Text('To: ${destination ?? ''}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              acceptTripRequest(tripId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              rejectTripRequest(tripId);
                            
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> acceptTripRequest(String tripId) async {
    // Fetch the current requests array
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<dynamic> requests = userDoc.get('requests') ?? [];

    // Remove the old request with req_status 1 and add the updated request with req_status 2
    requests.removeWhere(
        (request) => request['trip'] == tripId && request['req_status'] == 1);
    requests.add({
      'trip': tripId,
      'req_status': 2,
    });

    // Update the user's document with the modified requests array
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'requests': requests});

    // Fetch the current members array
    DocumentSnapshot tripDoc =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    List<dynamic> members = tripDoc.get('members') ?? [];

    // Update acceptance_status to 2 (accepted) for the current user
    members.forEach((member) {
      if (member['memberUid'] == FirebaseAuth.instance.currentUser!.uid) {
        member['acceptance_status'] = 2;
      }
    });

    // Update the trip's document with the modified members array
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .update({'members': members});

    // Add the trip reference to the user's trips field
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'trips': FieldValue.arrayUnion(
          [FirebaseFirestore.instance.collection('trips').doc(tripId)])
    });
  }

  Future<void> rejectTripRequest(String tripId) async {
    // Fetch the current requests array
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<dynamic> requests = userDoc.get('requests') ?? [];

    // Remove the old request with req_status 1 and add the updated request with req_status 0
    requests.removeWhere(
        (request) => request['trip'] == tripId && request['req_status'] == 1);
    requests.add({
      'trip': tripId,
      'req_status': 0,
    });

    // Update the user's document with the modified requests array
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'requests': requests});

    // Fetch the current members array
    DocumentSnapshot tripDoc =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    List<dynamic> members = tripDoc.get('members') ?? [];

    // Update acceptance_status to 0 (rejected) for the current user
    members.forEach((member) {
      if (member['memberUid'] == FirebaseAuth.instance.currentUser!.uid) {
        member['acceptance_status'] = 0;
      }
    });

    // Update the trip's document with the modified members array
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .update({'members': members});
  }
}

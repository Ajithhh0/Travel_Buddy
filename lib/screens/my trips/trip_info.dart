import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:travel_buddy/misc/shimmer_widget.dart';
import 'package:travel_buddy/screens/my%20trips/Navigation.dart/nav_map.dart';
import 'package:travel_buddy/screens/my%20trips/itinerary.dart';
import 'package:travel_buddy/screens/my%20trips/roles.dart';
import 'package:travel_buddy/screens/my%20trips/vehicle_config.dart';
import 'package:travel_buddy/screens/my%20trips/viewbudget.dart';

class TripInfo extends StatefulWidget {
  final String tripId;

  const TripInfo({
    Key? key,
    required this.tripId,
  }) : super(key: key);

  @override
  _TripInfoState createState() => _TripInfoState();
}

class _TripInfoState extends State<TripInfo> {
  DocumentSnapshot? tripSnapshot;
  late DocumentReference creatorRef;
  late String currentUserUid;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUserUid = user.uid;
        });
      }
    });

    _fetchTripData();
  }

  Future<void> _fetchTripData() async {
    try {
      FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        setState(() {
          tripSnapshot = snapshot;
          //creatorRef = tripSnapshot?['created_by'] as DocumentReference;
        });
      });
    } catch (e) {
      print('Error fetching trip data: $e');
    }
  }

  Widget _buildMemberTile(String memberUid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(memberUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _memberShimmer();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Text('No data found');
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final String userName = userData['username'] as String;
        final String avatarUrl = userData['avatar_url'] as String;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          title: Text(userName),
        );
      },
    );
  }
  
  Future<void> navigateToViewBudget() async {
  final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

  if (currentUserUid != null && tripSnapshot != null) {
    // Update the trip document with the budgetDocRef
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .set({
      // ... other trip data
      'budgetDocRef': FirebaseFirestore.instance
          .collection('budget')
          .doc(widget.tripId),
    }, SetOptions(merge: true));

    // Navigate to ViewBudget screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewBudget(
          tripId: widget.tripId,
        ),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    if (tripSnapshot == null) {
      // Return a loading indicator while fetching trip data
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Trip Details'),
          centerTitle: true,
          // shape: const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          // ),
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Build the UI with fetched trip data
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        centerTitle: true,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        // ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip details
            Center(
              child: Text(
                '${tripSnapshot?['trip_name']}',
                style:
                    const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12.0),
            Center(
                child: Text(
              'Invite ID : ${tripSnapshot?['invite_id']}',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            )),
            const SizedBox(height: 8.0),

            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(18.0),
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Starting From: ${tripSnapshot?['starting_from']}'),
                    const SizedBox(height: 8.0),
                    Text('Destination: ${tripSnapshot?['destination']}'),
                    const SizedBox(height: 8.0),
                    Text('Created At: ${tripSnapshot?['created_at']}'),
                    const SizedBox(height: 8.0),
                    Text('Type: ${tripSnapshot?['trip_type']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Members:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(tripSnapshot?['created_by'][0]['creatorUid'])
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> creatorSnapshot) {
                if (creatorSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _memberShimmer();
                } else if (creatorSnapshot.hasError) {
                  return const Text('Error fetching creator data');
                } else {
                  Map<String, dynamic> creatorData =
                      creatorSnapshot.data!.data() as Map<String, dynamic>;
                  String creatorUsername =
                      creatorData['username'] ?? 'Unknown User';
                  String creatorAvatarUrl = creatorData['avatar_url'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(creatorAvatarUrl),
                    ),
                    title: Text(creatorUsername),
                    subtitle: const Text('Trip Admin'),
                  );
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tripSnapshot?['members'].length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> memberData =
                      tripSnapshot?['members'][index] as Map<String, dynamic>;
                  final String memberUid = memberData['memberUid'] as String;
                  final int acceptanceStatus =
                      memberData['acceptance_status'] as int;

                  // Check if the current user is the admin
                  if (currentUserUid ==
                      tripSnapshot?['created_by'][0]['creatorUid']) {
                    // Admin sees all members
                    return _buildMemberTile(memberUid);
                  }

                  // Check if the current user is a member and has acceptance status 2
                  if (currentUserUid == memberUid && acceptanceStatus == 2) {
                    // Show the current user with acceptance status 2
                    return _buildMemberTile(memberUid);
                  }

                  // Show other members with acceptance status 2
                  if (acceptanceStatus == 2) {
                    return _buildMemberTile(memberUid);
                  }

                  // If conditions don't match, return an empty container
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                navigateToViewBudget();
              },
              icon: Icon(Icons.attach_money), // Budget icon
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehicleConfig(),
                  ),
                );
              },
              icon: Icon(Icons.directions_car), // Vehicle configuration icon
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RolesScreen(tripId: widget.tripId),
                  ),
                );
              },
              icon: Icon(Icons.people), // Roles icon
            ),
            IconButton(
              onPressed: () {
                // Navigate to itinerary screen
                // Replace `ItineraryScreen` with the actual screen for itinerary
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItineraryScreen(tripId: widget.tripId,),
                  ),
                );
              },
              icon: Icon(Icons.list), // Itinerary icon
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NavMap(),
            ),
          );
        },
        label: const Text(
          'Start Trip',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.start_outlined,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _memberShimmer() => ListTile(
        leading: ShimmerWidget.circular(
          height: 64,
          width: 64,
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: ShimmerWidget.rectangular(
              width: MediaQuery.of(context).size.width * 0.3, height: 16),
        ),
        subtitle: ShimmerWidget.rectangular(height: 10),
      );
}

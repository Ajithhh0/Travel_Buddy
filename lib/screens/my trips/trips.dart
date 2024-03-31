import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:travel_buddy/misc/shimmer_widget.dart';
import 'package:travel_buddy/screens/my%20trips/trip_info.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';

class Trips extends StatefulWidget {
  @override
  _TripsState createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  bool _showMyTrips = true;
  bool _showDeleted = false;
  bool _showArchived = false;

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userData.exists) {
        return userData.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print("Error fetching user data: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Text(
                _showDeleted
                    ? 'Deleted'
                    : _showArchived
                        ? 'Archived'
                        : _showMyTrips
                            ? 'My Trips'
                            : 'Error',
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showMyTrips = true;
                _showDeleted = false;
                _showArchived = false;
              });
            },
            icon: const Icon(Icons.list),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showDeleted = !_showDeleted;
                if (_showDeleted) {
                  _showArchived = false;
                  _showMyTrips = false;
                }
              });
            },
            icon: Icon(_showDeleted ? Icons.delete : Icons.delete_outline),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
                if (_showArchived) {
                  _showDeleted = false;
                  _showMyTrips = false;
                }
              });
            },
            icon: Icon(_showArchived ? Icons.archive : Icons.archive_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              print('User document not found.');
              return const Center(
                child: Text('User document not found.'),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final List<DocumentReference> tripRefs =
                (userData['trips'] as List<dynamic>)
                        .map((ref) => ref as DocumentReference)
                        .toList() ??
                    [];

            if (tripRefs.isEmpty) {
              return const Center(
                child: Text('No trips added.'),
              );
            }

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('trips')
                  .where(FieldPath.documentId,
                      whereIn: tripRefs.map((ref) => ref.id).toList())
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> tripSnapshot) {
                if (tripSnapshot.hasError) {
                  print('Error: ${tripSnapshot.error}');
                  return Center(
                    child: Text('Error: ${tripSnapshot.error}'),
                  );
                }

                if (!tripSnapshot.hasData || tripSnapshot.data!.docs.isEmpty) {
                  print('No trips available.');
                  return const Center(
                    child: Text('No trips available.'),
                  );
                }

                return ListView.builder(
                    itemCount: tripSnapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot tripDocument =
                          tripSnapshot.data!.docs[index];

                      // Fetch user data for the creator of this trip
                      Future<Map<String, dynamic>> userDataFuture =
                          getUserData(tripDocument['created_by'].id);

                      return FutureBuilder(
                        future: userDataFuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<Map<String, dynamic>> userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return tripShimmer();
                          } else if (userSnapshot.hasError) {
                            return const Text('Error fetching user data');
                          } else {
                            // Extract user data
                            Map<String, dynamic> userData = userSnapshot.data!;
                            String username =
                                userData['username'] ?? 'Unknown User';
                            String avatarUrl = userData['avatar_url'] ?? '';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TripInfo(
                                      tripId: tripDocument.id,
                                    ),
                                  ),
                                );
                              },
                              child: Slidable(
                                startActionPane: ActionPane(
                                  motion: const StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        if (_showDeleted) {
                                          restoreTrip(tripDocument.id);
                                        } else if (_showArchived) {
                                          restoreTrip(tripDocument.id);
                                        } else if (_showMyTrips) {
                                          archiveTrip(tripDocument.id);
                                        }
                                      },
                                      backgroundColor: Colors.blue,
                                      icon: _showMyTrips
                                          ? Icons.archive_outlined
                                          : Icons.restore,
                                    ),
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  motion: const StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) =>
                                          {softDeleteTrip(tripDocument.id)},
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete_outline,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(8.0),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(26.0),
                                      bottomLeft: Radius.circular(26.0),
                                      bottomRight: Radius.circular(26.0),
                                      topRight: Radius.circular(26.0),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Colors.amber, Colors.orange],
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(avatarUrl),
                                      radius: 20.0,
                                    ),
                                    title: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Center(
                                        child: Text(
                                          '${tripDocument['trip_name']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Created By: $username'),
                                        const SizedBox(
                                          height: 4.0,
                                        ),
                                        Text(
                                            'Starting From: ${tripDocument['starting_from']}'),
                                        const SizedBox(
                                          height: 4.0,
                                        ),
                                        Text(
                                            'Destination: ${tripDocument['destination']}'),
                                        const SizedBox(
                                          height: 4.0,
                                        ),
                                        Text(
                                            'Created At: ${tripDocument['created_at']}'),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    });
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> archiveTrip(String tripId) async {
    await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
      'status': 2, // Archived
    });
  }

  Future<void> softDeleteTrip(String tripId) async {
    await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
      'status': 0, // Soft Deleted
    });
  }

  Future<void> restoreTrip(String tripId) async {
    await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
      'status': 1, // Restored
    });
  }

  Future<void> _refreshData() async {
    setState(() {}); // Just rebuild the widget
  }

  Widget tripShimmer() => ListTile(leading: ShimmerWidget.circular(height: 64, width: 64,),
    title: Align(
      alignment: Alignment.centerLeft,
      child: ShimmerWidget.rectangular(
        width: MediaQuery.of(context).size.width * 0.3 ,
        height: 16),
    ),
    subtitle: ShimmerWidget.rectangular(height: 10),
  );
}

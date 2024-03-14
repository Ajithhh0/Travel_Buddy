import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:travel_buddy/screens/my%20trips/trip_info.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';
import 'archived.dart';

class Trips extends StatefulWidget {
  @override
  _TripsState createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  bool _showMyTrips = true; // Flag to show only trips with status 1 by default
  bool _showDeleted = false;
  bool _showArchived = false;

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
              .collection('trips')
              .where('status',
                  isEqualTo: _showDeleted
                      ? 0
                      : _showArchived
                          ? 2
                          : _showMyTrips
                              ? 1
                              : null) // Pass null if _showMyTrips is false
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No trips available.'),
              );
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripInfo(
                          tripData: data,
                          
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
                              restoreTrip(context, data['trip_name']);
                            } else if (_showArchived) {
                              restoreTrip(context, data['trip_name']);
                            } else if (_showMyTrips) {
                              archiveTrip(context, data['trip_name']);
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
                              softDeleteTrip(context, data['trip_name']),
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
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Center(
                            child: Text(
                              '${data['trip_name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Starting From: ${data['starting_from']}'),
                            const SizedBox(
                              height: 4.0,
                            ),
                            Text('Destination: ${data['destination']}'),
                            const SizedBox(
                              height: 4.0,
                            ),
                            Text('Created At: ${data['created_at']}'),
                            const SizedBox(
                              height: 8.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Future<void> softDeleteTrip(BuildContext context, String tripName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final tripDocRef = userDocRef.collection('trips').doc(tripName);

      try {
        await tripDocRef.update({
          'status': 0,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip "$tripName" deleted successfully.'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to soft delete trip: $e'),
          ),
        );
      }
    }
  }

  Future<void> restoreTrip(BuildContext context, String tripName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final tripDocRef = userDocRef.collection('trips').doc(tripName);

      try {
        await tripDocRef.update({
          'status': 1,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip "$tripName" restored successfully.'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore trip: $e'),
          ),
        );
      }
    }
  }

  Future<void> archiveTrip(BuildContext context, String tripName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final tripDocRef = userDocRef.collection('trips').doc(tripName);

      try {
        await tripDocRef.update({
          'status': 2,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip "$tripName" archived successfully.'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to archive trip: $e'),
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {}); // Just rebuild the widget
  }

  List<Member> getMembers(Map<String, dynamic> tripData) {
    List<Member> members = [];
    return members;
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:travel_buddy/screens/my%20trips/trip_info.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';

class Archived extends StatefulWidget {
  @override
  _ArchivedState createState() => _ArchivedState();
}

class _ArchivedState extends State<Archived> {
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Trips'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('trips')
            .where('status', isEqualTo: 0) // Filter trips with status 0 (deleted)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No archieved trips.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  // Navigate to TripDetails screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripInfo(tripData: data,
                      ),
                    ),
                  );
                },
                child: Slidable(
                  endActionPane: ActionPane(
                    motion: const StretchMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          restoreTrip(context, data['trip_name']);
                        },
                        backgroundColor: Colors.blue,
                        icon: Icons.restore,
                      ),
                      SlidableAction(
                        onPressed: (context) => permanentlyDeleteTrip(context, data['trip_name']),
                        backgroundColor: Colors.red,
                        icon: Icons.delete_forever,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey,
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
                          const SizedBox(height: 4.0,),
                          Text('Destination: ${data['destination']}'),
                          const SizedBox(height: 4.0,),
                          Text('Created At: ${data['created_at']}'),
                          const SizedBox(height: 8.0,),
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
    );
  }

  Future<void> restoreTrip(BuildContext context, String tripName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
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

  Future<void> permanentlyDeleteTrip(BuildContext context, String tripName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final tripDocRef = userDocRef.collection('trips').doc(tripName);

      try {
        
        await tripDocRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip "$tripName" permanently deleted.'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to permanently delete trip: $e'),
          ),
        );
      }
    }
  }

  List<Member> getMembers(Map<String, dynamic> tripData) {
    
    List<Member> members = [];
    return members;
  }
}

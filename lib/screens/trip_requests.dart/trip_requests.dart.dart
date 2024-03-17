import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('trip_requests_pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) {
            return Center(
              child: Text('No trip requests'),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final tripRequest = data[index].data() as Map<String, dynamic>;
              final tripName = tripRequest['trip_name'];
              final formattedDate = tripRequest['created_at'];
              final startLocation = tripRequest['starting_from'];
              final destination = tripRequest['destination'];
              final acceptanceStatus = tripRequest['acceptance_status'];

              // Check if the acceptance_status is 2 and save trip details under the recipient's UID
              if (acceptanceStatus == 2) {
                _saveTripDetailsUnderRecipient(
                  tripName,
                  formattedDate,
                  startLocation,
                  destination,
                  tripRequest['recipient_uid'],
                  context,
                );
                return SizedBox(); // Return an empty SizedBox to exclude the card from the UI
              }

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
                        icon: Icon(Icons.check),
                        onPressed: () {
                          _updateAcceptanceStatus(
                              data[index].id, 2, context);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _updateAcceptanceStatus(
                              data[index].id, 0, context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateAcceptanceStatus(
      String documentId, int newStatus, BuildContext context) async {
    try {
      // Reference to the current user's trip request document
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('trip_requests_pending')
          .doc(documentId);

      if (newStatus == 0) {
        // If the new status is 0, delete the document
        await docRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Trip request rejected and removed.'),
          ),
        );
      } else if (newStatus == 2) {
        // If the new status is 2, update the document with the new status
        await docRef.update({'acceptance_status': newStatus});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Trip request accepted.'),
          ),
        );
         await docRef.delete();
      } else {
        // Handle other status updates if needed
        await docRef.update({'acceptance_status': newStatus});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip request status updated to: $newStatus'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update trip request status: $error'),
        ),
      );
    }
  }

  Future<void> _saveTripDetailsUnderRecipient(
      String tripName,
      String formattedDate,
      String startLocation,
      String destination,
      String recipientUid,
      BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientUid)
          .collection('trips')
          .doc(tripName)
          .set({
        'trip_name': tripName,
        'starting_from': startLocation,
        'destination': destination,
        'status': 1,
        'created_at': formattedDate,
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save trip details: $error'),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripRequestsScreen extends StatelessWidget {
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trip_requests_pending')
            .where('recipient_uid', isEqualTo: currentUserUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!.docs;

          
    // Check if there are no pending trip requests
    final hasPendingRequests = data.any((tripRequest) {
      final acceptanceStatus = tripRequest['acceptance_status'];
      return acceptanceStatus == 1;
    });

    if (!hasPendingRequests) {
      return Center(
        child: Text('No pending trip requests'),
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

              if (acceptanceStatus != 1) {
                // Return an empty container to exclude the trip request from UI
                return Container();
                
              }

              // Check if the acceptance_status is 2 and save trip details under the recipient's UID
              // Inside your StreamBuilder where you check the acceptanceStatus
              if (acceptanceStatus == 2) {
                // Assuming tripId is available in your data model
                final tripId = tripRequest[
                    'trip_id']; // Make sure this field exists in your data model
                final recipientUid = tripRequest['recipient_uid'];

                // Call the function to save trip details under the recipient's UID
                _saveTripDetailsUnderRecipient(tripId, recipientUid, context);

                // Optionally, you can remove the trip request from the UI by not returning a Card
                // return SizedBox(); // Uncomment this line if you want to exclude the card from the UI
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
                          _updateAcceptanceStatus(data[index].id, 2, context);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _updateAcceptanceStatus(data[index].id, 0, context);
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
        .collection('trip_requests_pending')
        .doc(documentId);

    if (newStatus == 0) {
      
      await docRef.update({'acceptance_status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip request rejected and removed.'),
        ),
      );
    } else if (newStatus == 2) {
      // If the new status is 2, update the document with the new status
      await docRef.update({'acceptance_status': newStatus});
      
      // Call the function to save trip details under the recipient's UID
      final tripRequest = await docRef.get();
      final tripData = tripRequest.data() as Map<String, dynamic>;
      final tripId = tripData['trip_id'];
      final recipientUid = tripData['recipient_uid'];
      await _saveTripDetailsUnderRecipient(tripId, recipientUid, context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip request accepted.'),
        ),
      );
      
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
      String tripId, String recipientUid, BuildContext context) async {
    try {
      final tripRef =
          FirebaseFirestore.instance.collection('trips').doc(tripId);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientUid)
          .update({
        'trips': FieldValue.arrayUnion([tripRef])
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

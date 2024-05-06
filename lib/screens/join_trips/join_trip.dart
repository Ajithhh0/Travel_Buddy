import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinTripPage extends StatefulWidget {
  @override
  _JoinTripPageState createState() => _JoinTripPageState();
}

class _JoinTripPageState extends State<JoinTripPage> {
  final TextEditingController _inviteIdController = TextEditingController();
  String? _errorText;

  Future<void> _joinTrip(String inviteId) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid != null) {
      final tripQuery = await FirebaseFirestore.instance.collection('trips').where('invite_id', isEqualTo: inviteId).get();

      if (tripQuery.docs.isEmpty) {
        setState(() {
          _errorText = 'No trip found with this invite ID.';
        });
      } else {
        final tripDoc = tripQuery.docs.first;
        final tripRef = FirebaseFirestore.instance.collection('trips').doc(tripDoc.id);

        // Update trip document to add the current user as a member
        await tripRef.update({
          'members': FieldValue.arrayUnion([
            {
              'memberUid': currentUserUid,
              'acceptance_status': 2,
            }
          ])
        });

        // Update the current user's document to include a reference to the trip
        final userRef = FirebaseFirestore.instance.collection('users').doc(currentUserUid);
        await userRef.update({
          'trips': FieldValue.arrayUnion([tripRef])
        });

        
        setState(() {
          _errorText = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the trip.'),
          ),
        );
        
         Navigator.pop(context);
      }
    } else {
      // Handle if the current user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to join the trip.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Trip'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _inviteIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Invite ID',
                errorText: _errorText,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                final inviteId = _inviteIdController.text.trim();
                if (inviteId.isNotEmpty) {
                  _joinTrip(inviteId);
                } else {
                  setState(() {
                    _errorText = 'Please enter an invite ID.';
                  });
                }
              },
              child: Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}

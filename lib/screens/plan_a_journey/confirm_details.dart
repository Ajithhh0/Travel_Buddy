import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy/misc/app_info.dart';
import 'package:travel_buddy/misc/members_provider.dart';
import 'package:travel_buddy/screens/home_screen.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';
import 'package:intl/intl.dart';

typedef TripAcceptedCallback = void Function();

class ConfirmDetails extends StatefulWidget {
  final String? tripName;
  final List<Member> savedMembers;
  final TripAcceptedCallback? onTripAccepted;

  const ConfirmDetails({
    Key? key,
    this.tripName,
    required this.savedMembers,
    required String startingLocation,
    required String destinationLocation,
    this.onTripAccepted,
  }) : super(key: key);

  @override
  _ConfirmDetailsState createState() => _ConfirmDetailsState();
}

class _ConfirmDetailsState extends State<ConfirmDetails> {
  late String startLocation;
  late String destinationLocation;
  late List<Member> savedMembers;
  String? tripType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    startLocation = appInfo.startLocation?.humanReadableAddress ?? 'Not Available';
    destinationLocation = appInfo.destinationLocation?.humanReadableAddress ?? 'Not Available';
    savedMembers = widget.savedMembers;

    final List<DocumentReference> memberRefs = savedMembers
      .map((member) => FirebaseFirestore.instance.collection('users').doc(member.uid))
      .toList();
    Provider.of<MemberRefsProvider>(context, listen: false).updateMemberRefs(memberRefs);
  }

  String generateInviteId() {
    Random random = Random();
    int num = random.nextInt(900000) + 100000; 
    return num.toString();
  }

  Future<void> saveToDatabase() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final tripDetailsDocumentRef = FirebaseFirestore.instance.collection('trips').doc();
      final String tripId = tripDetailsDocumentRef.id;
      final List<DocumentReference> memberRefs = savedMembers
        .map((member) => FirebaseFirestore.instance.collection('users').doc(member.uid))
        .toList();
      Provider.of<MemberRefsProvider>(context, listen: false).updateMemberRefs(memberRefs);

      final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      List<Map<String, dynamic>> membersData = savedMembers.map((member) {
        return {
          'memberUid': member.uid,
          'acceptance_status': 1,
        };
      }).toList();

      //creator
      List<Map<String, dynamic>> creatorData = savedMembers.map((member) {
        return {
          'creatorUid': currentUser.uid,
          'acceptance_status': 2,
        };
      }).toList();

      String inviteId = generateInviteId();
      var data = {
        'trip_name': widget.tripName,
        'created_by': creatorData,
        'starting_from': startLocation,
        'destination': destinationLocation,
        'members': membersData,
        'created_at': formattedDate,
        'status': 1,
        'invite_id': inviteId,
        'trip_type': tripType,
      };

      await tripDetailsDocumentRef.set(data);

      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'trips': FieldValue.arrayUnion([FirebaseFirestore.instance.collection('trips').doc(tripId)])
      });

      for (final member in savedMembers) {
        await sendTripRequest(currentUser.uid, member.uid, formattedDate, tripId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your trip has been created.'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> sendTripRequest(String senderUid, String recipientUid, String formattedDate, String tripId) async {
    await FirebaseFirestore.instance.collection('users').doc(recipientUid).update({
      'requests': FieldValue.arrayUnion([
        {
          'trip': tripId,
          'req_status': 1,
        }
      ])
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your trip request has been sent.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Details'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Type: ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Private',
                  groupValue: tripType,
                  onChanged: (value) {
                    setState(() {
                      tripType = value;
                    });
                  },
                ),
                const Text('Private'),
                Radio<String>(
                  value: 'Public',
                  groupValue: tripType,
                  onChanged: (value) {
                    setState(() {
                      tripType = value;
                    });
                  },
                ),
                const Text('Public'),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Trip Name: ${widget.tripName ?? ''}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.black),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Starting From: $startLocation',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Destination : $destinationLocation',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const Text(
              'Members:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.black,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: savedMembers.length,
                itemBuilder: (context, index) {
                  final member = savedMembers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(member.avatarUrl),
                    ),
                    title: Text(member.name, style: const TextStyle(color: Colors.white)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomAppBar(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {
                    setState(() {
                      if (tripType == null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Alert'),
                            content: const Text('Please select the type of trip.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        saveToDatabase();
                      }
                    });
                  },
                  child: const Text('Create Trip', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

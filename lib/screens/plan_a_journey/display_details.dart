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
  late List<Member> savedMembers; // Declare savedMembers here

  @override
  void initState() {
    super.initState();
    // Retrieve start and destination locations from the provider
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    startLocation =
        appInfo.startLocation?.humanReadableAddress ?? 'Not Available';
    destinationLocation =
        appInfo.destinationLocation?.humanReadableAddress ?? 'Not Available';
    savedMembers = widget.savedMembers;

    final List<DocumentReference> memberRefs = savedMembers
        .map((member) =>
            FirebaseFirestore.instance.collection('users').doc(member.uid))
        .toList();
    Provider.of<MemberRefsProvider>(context, listen: false)
        .updateMemberRefs(memberRefs);
  }

Future<void> saveToDatabase() async {
 final currentUser = FirebaseAuth.instance.currentUser;
 if (currentUser != null) {
    final tripDetailsDocumentRef = FirebaseFirestore.instance.collection('trips').doc();

    final String tripId = tripDetailsDocumentRef.id;

    final List<DocumentReference> memberRefs = savedMembers
        .map((member) => FirebaseFirestore.instance.collection('users').doc(member.uid))
        .toList();

    // Update the MemberRefsProvider with the new memberRefs
    Provider.of<MemberRefsProvider>(context, listen: false).updateMemberRefs(memberRefs);

    final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    var data = {
      'trip_name': widget.tripName,
      'created_by': FirebaseFirestore.instance.collection('users').doc(currentUser.uid), // User Reference
      'starting_from': startLocation,
      'destination': destinationLocation,
      'members': memberRefs,
      'created_at': formattedDate,
      'status': 1,
    };

    await tripDetailsDocumentRef.set(data);

    print("Trip ID: $tripId");

    // Update the user's document to include a reference to the newly created trip
    await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
      'trips': FieldValue.arrayUnion([FirebaseFirestore.instance.collection('trips').doc(tripId)])
    });

    for (final member in savedMembers) {
      await sendTripRequest(currentUser.uid, member.uid, formattedDate, tripId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Your trip has been created.'),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
 }
}


  Future<void> sendTripRequest(
    String senderUid, String recipientUid, String formattedDate, String tripId) async {
      
 final List<DocumentReference> memberRefs = savedMembers
      .map((member) =>
          FirebaseFirestore.instance.collection('users').doc(member.uid))
      .toList();

 final tripRequestData = {
    'trip_id' : tripId,
    'trip_name': widget.tripName,
    'starting_from': startLocation,
    'destination': destinationLocation,
    'sender_uid': senderUid,
    'recipient_uid': recipientUid,
    'acceptance_status': 1,
    'created_at': formattedDate,
    'members': memberRefs,
 };

 final tripRequestRef = await FirebaseFirestore.instance
      .collection('trip_requests_pending')
      .add(tripRequestData);

 print(
      'Trip request sent to: $recipientUid, Document ID: ${tripRequestRef.id}');

 // Check the acceptance status
 

 ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Your trip request has been sent.'),
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
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Trip Name: ${widget.tripName ?? ''}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              color: const Color.fromARGB(255, 151, 196, 232),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: savedMembers.length,
                itemBuilder: (context, index) {
                  final member = savedMembers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(member.avatarUrl),
                    ),
                    title: Text(member.name),
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
          color: const Color.fromARGB(255, 151, 196, 232),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    saveToDatabase();
                  },
                  child: const Text('Create Trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

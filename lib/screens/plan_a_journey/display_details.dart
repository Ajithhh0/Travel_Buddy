import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy/misc/app_info.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';

class ConfirmDetails extends StatefulWidget {
  final String? tripName;
  final List<Member> savedMembers;

  const ConfirmDetails({
    Key? key,
    this.tripName,
    required this.savedMembers,
    required String startingLocation,
    required String destinationLocation,
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
    startLocation = appInfo.startLocation?.humanReadableAddress ?? 'Not Available';
    destinationLocation = appInfo.destinationLocation?.humanReadableAddress ?? 'Not Available';
    savedMembers = widget.savedMembers; // Initialize savedMembers here
  }

 Future<void> saveToDatabase() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    final tripDetailsCollectionRef = userDocRef.collection('trips').doc(widget.tripName).collection('trip_details');

    final List<String> memberUserIds = savedMembers.map((member) => member.uid).toList();

    // Save trip details directly under the "trip_details" collection
    await tripDetailsCollectionRef.doc('trip_details').set({
      'trip_name': widget.tripName,
      'starting_from': startLocation,
      'destination': destinationLocation,
      'members': memberUserIds, // Use only the user IDs
    });
  }
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
        backgroundColor: const Color.fromARGB(255, 151, 196, 232),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              color: Colors.grey,
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
          color: Colors.grey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: saveToDatabase,
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

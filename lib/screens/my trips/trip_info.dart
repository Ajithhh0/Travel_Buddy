import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_buddy/screens/my%20trips/viewbudget.dart';

class TripInfo extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const TripInfo({Key? key, required this.tripData}) : super(key: key);

  @override
  _TripInfoState createState() => _TripInfoState();
}

class _TripInfoState extends State<TripInfo> {
  late List<dynamic> memberReferences;
  late DocumentReference creatorRef;

  @override
  void initState() {
    super.initState();
    memberReferences = widget.tripData['members'];
    creatorRef = widget.tripData['created_by'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip details
            Center(
              child: Text(
                '${widget.tripData['trip_name']}',
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12.0),
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
                    Text('Starting From: ${widget.tripData['starting_from']}'),
                    const SizedBox(height: 8.0),
                    Text('Destination: ${widget.tripData['destination']}'),
                    const SizedBox(height: 8.0),
                    Text('Created At: ${widget.tripData['created_at']}'),
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
              future: creatorRef.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Text('No data found');
                }
                final creatorData = snapshot.data!.data() as Map<String, dynamic>;
                final creatorName = creatorData['username'];
                final creatorAvatarUrl = creatorData['avatar_url'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(creatorAvatarUrl),
                  ),
                  title: Text(creatorName),
                  subtitle: const Text('Trip Admin'),
                );
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: memberReferences.length,
                itemBuilder: (context, index) {
                  final DocumentReference memberRef = memberReferences[index];

                  return FutureBuilder<DocumentSnapshot>(
                    future: memberRef.get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const Text('No data found');
                      }

                      final userData = snapshot.data!.data() as Map<String, dynamic>;
                      final userName = userData['username'];
                      final avatarUrl = userData['avatar_url'];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                        title: Text(userName),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewBudget(
                            tripName: '',
                          )),
                );
              },
              child: Container(
                height: 40,
                alignment: Alignment.bottomLeft,
                child: const Text('Budget'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ViewBudget(
                      tripName: '',
                    )),
          );
        },
        label: const Text('Start Trip'),
        icon: const Icon(Icons.start_outlined),
      ),
    );
  }
}

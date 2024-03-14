import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_buddy/screens/my%20trips/viewbudget.dart';
 // Importing Budget.dart

class TripInfo extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const TripInfo({Key? key, required this.tripData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> memberReferences = tripData['members'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: const Color.fromARGB(255, 151, 196, 232),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip details
            Center(
              child: Text(
                '${tripData['trip_name']}',
                style:
                    const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
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
                    Text('Starting From: ${tripData['starting_from']}'),
                    const SizedBox(height: 8.0),
                    Text('Destination: ${tripData['destination']}'),
                    const SizedBox(height: 8.0),
                    Text('Created At: ${tripData['created_at']}'),
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

                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;
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
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewBudget(tripName: '',)), // Navigate to Budget.dart
            );
          },
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: const Text('Budget'),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_buddy/screens/plan_a_journey/budget_planner.dart';
import 'package:travel_buddy/screens/plan_a_journey/models/trip_model.dart';

class TripPlanning extends StatefulWidget {
  final TripDetails tripDetails;
  const TripPlanning({Key? key, required this.tripDetails}) : super(key: key);

  @override
  State<TripPlanning> createState() => _TripPlanningState();
}

class _TripPlanningState extends State<TripPlanning> {
  String? tripName;
  String? username;
  List<Map<String, dynamic>> members = [];
  late List<Member> savedMembers; // Define savedMembers

  @override
  void initState() {
    super.initState();
    savedMembers = []; // Initialize savedMembers list
  }

  @override
  Widget build(BuildContext context) {
    // Access startingLocation and destinationLocation from tripDetails
    String? startingLocation = widget.tripDetails.startingLocation;
    String? destinationLocation = widget.tripDetails.destinationLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Planning'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: const Color.fromARGB(255, 151, 196, 232),
        elevation: 20,
        flexibleSpace: const ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(1000),
            bottomRight: Radius.circular(1000),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Trip Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    tripName = val;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    username = val;
                  });
                },
              ),
            ),
            if (members.isNotEmpty)
              Card(
                color: Colors.grey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Members:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(member['avatar_url'] ?? ''),
                          ),
                          title: Text(member['username'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                members.removeAt(index);
                                savedMembers.removeAt(index); // Remove member from savedMembers
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (username != null && username!.isNotEmpty)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('username', isGreaterThanOrEqualTo: username)
                    .where('username', isLessThan: username! + 'z')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final List<DocumentSnapshot> users =
                      snapshot.data!.docs.cast<DocumentSnapshot>();

                  if (users.isEmpty) {
                    return const Center(
                      child: Text('No User Found'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      // Check if the user is already added
                      bool isAdded = members.any(
                          (member) => member['username'] == user['username']);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(user['avatar_url'] ?? ''),
                        ),
                        title: Text(user['username'] ?? ''),
                        onTap: () {
                          // Only add if the user is not already added
                          if (!isAdded) {
                            setState(() {
                              members.add({
                                'avatar_url': user['avatar_url'],
                                'username': user['username'],
                                'uid': user.id, // Add UID of the user
                              });
                              print('Added user UID: ${user.id}');

                              // Add UID to savedMembers
                              savedMembers.add(Member(
                                name: user['username'],
                                avatarUrl: user['avatar_url'],
                                uid: user.id,
                              ));
                            });
                          }
                        },
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: members.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                if (members.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BudgetPlanner(
                        tripName: tripName,
                        savedMembers: savedMembers, // Pass savedMembers directly
                        startingLocation: startingLocation ?? '',
                        destinationLocation: destinationLocation ?? '',
                      ),
                    ),
                  );
                }
              },
              child: const Icon(Icons.next_plan),
            )
          : null,
    );
  }
}
